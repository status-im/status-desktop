import NimQml, strutils, logging, json

import backend/wallet_connect as backend

import app/global/global_singleton
import app/core/eventemitter
import app/core/signals/types

import app_service/common/utils as common_utils

import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

import constants
import session_response_dto, helper

const UNIQUE_WALLET_CONNECT_MODULE_SIGNING_IDENTIFIER* = "WalletConnect-Signing"

QtObject:
  type
    Controller* = ref object of QObject
      events: EventEmitter
      sessionRequestJson: JsonNode

  ## Forward declarations
  proc onDataSigned(self: Controller, keyUid: string, path: string, r: string, s: string, v: string, pin: string)
  proc finishSessionRequest(self: Controller, signature: string)

  proc setup(self: Controller) =
    self.QObject.setup

    # Register for wallet events
    self.events.on(SignalType.Wallet.event, proc(e: Args) =
      # TODO #12434: async processing
      discard
    )

    self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DATA_SIGNED) do(e: Args):
      let args = SharedKeycarModuleArgs(e)
      if args.uniqueIdentifier != UNIQUE_WALLET_CONNECT_MODULE_SIGNING_IDENTIFIER:
        return
      self.onDataSigned(args.keyUid, args.path, args.r, args.s, args.v, args.pin)

  proc delete*(self: Controller) =
    self.QObject.delete

  proc newController*(events: EventEmitter): Controller =
    new(result, delete)
    result.events = events
    result.setup()

  proc onDataSigned(self: Controller, keyUid: string, path: string, r: string, s: string, v: string, pin: string) =
    if keyUid.len == 0 or path.len == 0 or r.len == 0 or s.len == 0 or v.len == 0 or pin.len == 0:
      error "invalid data signed"
      return
    let signature = "0x" & r & s & v
    self.finishSessionRequest(signature)

  # supportedNamespaces is a Namespace as defined in status-go: services/wallet/walletconnect/walletconnect.go
  proc proposeUserPair*(self: Controller, sessionProposalJson: string, supportedNamespacesJson: string) {.signal.}

  proc pairSessionProposal(self: Controller, sessionProposalJson: string) {.slot.} =
    var res: JsonNode
    let err = backend.pair(res, sessionProposalJson)
    if err.len > 0:
      error "Failed to pair session"
      return
    let sessionProposalJson = if res.hasKey("sessionProposal"): $res["sessionProposal"] else: ""
    let supportedNamespacesJson = if res.hasKey("supportedNamespaces"): $res["supportedNamespaces"] else: ""
    self.proposeUserPair(sessionProposalJson, supportedNamespacesJson)

  proc respondSessionRequest*(self: Controller, sessionRequestJson: string, signedJson: string, error: bool) {.signal.}

  proc sendTransactionAndRespond(self: Controller, signature: string) =
    let finalSignature = singletonInstance.utils.removeHexPrefix(signature)
    var res: JsonNode
    let err = backend.sendTransactionWithSignature(res, finalSignature)
    if err.len > 0:
      error "Failed to send tx"
      return
    let txHash = res.getStr
    self.respondSessionRequest($self.sessionRequestJson, txHash, false)

  proc buildRawTransactionAndRespond(self: Controller, signature: string) =
    let finalSignature = singletonInstance.utils.removeHexPrefix(signature)
    var res: JsonNode
    let err = backend.buildRawTransaction(res, finalSignature)
    if err.len > 0:
      error "Failed to send tx"
      return
    let txHash = res.getStr
    self.respondSessionRequest($self.sessionRequestJson, txHash, false)

  proc finishSessionRequest(self: Controller, signature: string) =
    let requestMethod = getRequestMethod(self.sessionRequestJson)
    if requestMethod == RequestMethod.SendTransaction:
      self.sendTransactionAndRespond(signature)
    elif requestMethod == RequestMethod.SignTransaction:
      self.buildRawTransactionAndRespond(signature)
    elif requestMethod == RequestMethod.PersonalSign:
      self.respondSessionRequest($self.sessionRequestJson, signature, false)
    elif requestMethod == RequestMethod.EthSign:
      self.respondSessionRequest($self.sessionRequestJson, signature, false)
    elif requestMethod == RequestMethod.SignTypedData:
      self.respondSessionRequest($self.sessionRequestJson, signature, false)
    else:
      error "Unknown request method"

  proc sessionRequest*(self: Controller, sessionRequestJson: string, password: string) {.slot.} =
    try:
      self.sessionRequestJson = parseJson(sessionRequestJson)
      var sessionRes: JsonNode
      let err = backend.sessionRequest(sessionRes, sessionRequestJson)
      if err.len > 0:
        error "Failed to request a session"
        self.respondSessionRequest($sessionRequestJson, "", true)
        return

      let sessionResponseDto = sessionRes.toSessionResponseDto()
      if sessionResponseDto.signOnKeycard:
        let data = SharedKeycarModuleSigningArgs(uniqueIdentifier: UNIQUE_WALLET_CONNECT_MODULE_SIGNING_IDENTIFIER,
          keyUid: sessionResponseDto.keyUid,
          path: sessionResponseDto.addressPath,
          dataToSign: singletonInstance.utils.removeHexPrefix(sessionResponseDto.messageToSign))
        self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_SIGN_DATA, data)
      else:
        let hashedPasssword = common_utils.hashPassword(password)
        var signMsgRes: JsonNode
        let err = backend.signMessage(signMsgRes,
          sessionResponseDto.messageToSign,
          sessionResponseDto.address,
          hashedPasssword)
        if err.len > 0:
          error "Failed to sign message on statusgo side"
          return
        let signature = signMsgRes.getStr
        self.finishSessionRequest(signature)
    except:
      error "session request action failed"

  proc getProjectId*(self: Controller): string {.slot.} =
    return constants.WALLET_CONNECT_PROJECT_ID
  QtProperty[string] projectId:
    read = getProjectId