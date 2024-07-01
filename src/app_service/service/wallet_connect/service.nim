import NimQml, chronicles, times, json

import backend/wallet_connect as status_go
import backend/wallet

import app_service/service/settings/service as settings_service
import app_service/common/wallet_constants
from app_service/service/transaction/dto import PendingTransactionTypeDto

import app/global/global_singleton

import app/core/eventemitter
import app/core/signals/types
import app/core/tasks/[threadpool]

import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "wallet-connect-service"

# include async_tasks

const UNIQUE_WALLET_CONNECT_MODULE_IDENTIFIER* = "WalletSection-WCModule"

type
  AuthenticationResponseFn* = proc(password: string, pin: string, success: bool)

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service

    authenticationCallback: AuthenticationResponseFn

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    settingsService: settings_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup

    result.events = events
    result.threadpool = threadpool
    result.settingsService = settings_service

  proc init*(self: Service) =
    self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
      let args = SharedKeycarModuleArgs(e)
      if args.uniqueIdentifier != UNIQUE_WALLET_CONNECT_MODULE_IDENTIFIER:
        return

      if self.authenticationCallback == nil:
        error "unexpected user authenticated event; no callback set"
        return
      defer:
        self.authenticationCallback = nil

      if args.password == "" and args.pin == "":
        info "fail to authenticate user"
        self.authenticationCallback("", "", false)
        return

      self.authenticationCallback(args.password, args.pin, true)

  proc addSession*(self: Service, session_json: string): bool =
    # TODO #14588: call it async
    return status_go.addSession(session_json)

  proc deactivateSession*(self: Service, topic: string): bool =
    # TODO #14588: call it async
    return status_go.disconnectSession(topic)

  proc updateSessionsMarkedAsActive*(self: Service, activeTopicsJson: string) =
    # TODO #14588: call it async
    let activeTopicsJN = parseJson(activeTopicsJson)
    if activeTopicsJN.kind != JArray:
      error "invalid array of json strings"
      return

    var activeTopics = newSeq[string]()
    for i in 0 ..< activeTopicsJN.len:
      if activeTopicsJN[i].kind != JString:
        error "bad topic entry at", i
        return
      activeTopics.add(activeTopicsJN[i].getStr())

    let sessions = status_go.getActiveSessions(0)
    if sessions.isNil:
      error "failed to get active sessions"
      return

    for session in sessions:
      if session.kind != JObject or not session.hasKey("topic"):
        error "unexpected session object"
        continue

      let topic = session["topic"].getStr()
      if not activeTopics.contains(topic):
        if not status_go.disconnectSession(topic):
          error "failed to mark session as disconnected", topic

  proc getDapps*(self: Service): string =
    let validAtEpoch = now().toTime().toUnix()
    let testChains = self.settingsService.areTestNetworksEnabled()
    # TODO #14588: call it async
    return status_go.getDapps(validAtEpoch, testChains)

  # Will fail if another authentication is in progress
  proc authenticateUser*(self: Service, keyUid: string, callback: AuthenticationResponseFn): bool =
    if self.authenticationCallback != nil:
      return false
    self.authenticationCallback = callback

    let data = SharedKeycarModuleAuthenticationArgs(
      uniqueIdentifier: UNIQUE_WALLET_CONNECT_MODULE_IDENTIFIER,
      keyUid: keyUid)

    self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)
    return true

  proc signMessageUnsafe*(self: Service, address: string, password: string, message: string): string =
    return status_go.signMessageUnsafe(address, password, message)

  proc signMessage*(self: Service, address: string, password: string, message: string): string =
    return status_go.signMessage(address, password, message)

  proc safeSignTypedData*(self: Service, address: string, password: string, typedDataJson: string, chainId: int, legacy: bool): string =
    return status_go.safeSignTypedData(address, password, typedDataJson, chainId, legacy)

  proc signTransaction*(self: Service, address: string, chainId: int, password: string, txJson: string): string =
    var buildTxResponse: JsonNode
    var err = wallet.buildTransaction(buildTxResponse, chainId, txJson)
    if err.len > 0:
      error "status-go - wallet_buildTransaction failed", err=err
      return ""
    if buildTxResponse.isNil or buildTxResponse.kind != JsonNodeKind.JObject or
      not buildTxResponse.hasKey("txArgs") or not buildTxResponse.hasKey("messageToSign"):
        error "unexpected wallet_buildTransaction response"
        return ""
    var txToBeSigned = buildTxResponse["messageToSign"].getStr
    if txToBeSigned.len != wallet_constants.TX_HASH_LEN_WITH_PREFIX:
      error "unexpected tx hash length"
      return ""

    var signMsgRes: JsonNode
    err = wallet.signMessage(signMsgRes,
          txToBeSigned,
          address,
          hashPassword(password))
    if err.len > 0:
      error "status-go - wallet_signMessage failed", err=err
    let signature = singletonInstance.utils.removeHexPrefix(signMsgRes.getStr)

    var txResponse: JsonNode
    err = wallet.buildRawTransaction(txResponse, chainId, $buildTxResponse["txArgs"], signature)
    if err.len > 0:
      error "status-go - wallet_buildRawTransaction failed", err=err
      return ""
    if txResponse.isNil or txResponse.kind != JsonNodeKind.JObject or not txResponse.hasKey("rawTx"):
      error "unexpected buildRawTransaction response"
      return ""

    return txResponse["rawTx"].getStr

  proc sendTransaction*(self: Service, address: string, chainId: int, password: string, txJson: string): string =
    var buildTxResponse: JsonNode
    var err = wallet.buildTransaction(buildTxResponse, chainId, txJson)
    if err.len > 0:
      error "status-go - wallet_buildTransaction failed", err=err
      return ""
    if buildTxResponse.isNil or buildTxResponse.kind != JsonNodeKind.JObject or
      not buildTxResponse.hasKey("txArgs") or not buildTxResponse.hasKey("messageToSign"):
        error "unexpected wallet_buildTransaction response"
        return ""
    var txToBeSigned = buildTxResponse["messageToSign"].getStr
    if txToBeSigned.len != wallet_constants.TX_HASH_LEN_WITH_PREFIX:
      error "unexpected tx hash length"
      return ""

    var signMsgRes: JsonNode
    err = wallet.signMessage(signMsgRes,
          txToBeSigned,
          address,
          hashPassword(password))
    if err.len > 0:
      error "status-go - wallet_signMessage failed", err=err
    let signature = singletonInstance.utils.removeHexPrefix(signMsgRes.getStr)

    var txResponse: JsonNode
    err = wallet.sendTransactionWithSignature(txResponse, chainId,
            $PendingTransactionTypeDto.WalletConnectTransfer, $buildTxResponse["txArgs"], signature)
    if err.len > 0:
      error "status-go - sendTransactionWithSignature failed", err=err
      return ""
    if txResponse.isNil or txResponse.kind != JsonNodeKind.JString:
      error "unexpected sendTransactionWithSignature response"
      return ""

    return txResponse.getStr
