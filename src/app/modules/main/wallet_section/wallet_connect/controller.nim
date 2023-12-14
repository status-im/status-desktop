import NimQml, strutils, logging, json, options, chronicles

import backend/wallet as backend_wallet
import backend/wallet_connect as backend_wallet_connect

import app/global/global_singleton
import app/global/app_signals
import app/core/eventemitter
import app/core/signals/types
import app/global/app_signals

import app_service/common/utils as common_utils
from app_service/service/transaction/dto import PendingTransactionTypeDto
import app_service/service/wallet_account/service as wallet_account_service

import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

import constants
import tx_response_dto, helpers

const UNIQUE_WC_SESSION_REQUEST_SIGNING_IDENTIFIER* = "WalletConnect-SessionRequestSigning"
const UNIQUE_WC_AUTH_REQUEST_SIGNING_IDENTIFIER* = "WalletConnect-AuthRequestSigning"

logScope:
  topics = "wallet-connect"

QtObject:
  type
    Controller* = ref object of QObject
      events: EventEmitter
      walletAccountService: wallet_account_service.Service
      sessionRequestJson: JsonNode
      txResponseDto: TxResponseDto
      hasActivePairings: bool

  ## Forward declarations
  proc invalidateData(self: Controller)
  proc setHasActivePairings*(self: Controller, value: bool)
  proc onDataSigned(self: Controller, keyUid: string, path: string, r: string, s: string, v: string, pin: string, identifier: string)
  proc finishSessionRequest(self: Controller, signature: string)
  proc finishAuthRequest(self: Controller, signature: string)

  ## signals
  proc checkPairings*(self: Controller) {.signal.}
  proc requestOpenWalletConnectPopup*(self: Controller, uri: string) {.signal.}
  proc hasActivePairingsChanged*(self: Controller) {.signal.}
  proc respondSessionProposal*(self: Controller, sessionProposalJson: string, supportedNamespacesJson: string, error: string) {.signal.}
  proc respondSessionRequest*(self: Controller, sessionRequestJson: string, signedJson: string, error: bool) {.signal.}
  proc respondAuthRequest*(self: Controller, signature: string, error: bool) {.signal.}

  proc setup(self: Controller) =
    self.QObject.setup

    # Register for wallet events
    self.events.on(SignalType.Wallet.event, proc(e: Args) =
      # TODO #12434: async processing
      discard
    )

    self.events.on(SIGNAL_STATUS_URL_ACTIVATED) do(e: Args):
      var args = StatusUrlArgs(e)
      let (found, wcUri) = extractAndCheckUriParameter(args.url)
      if found:
        self.requestOpenWalletConnectPopup(wcUri)

    self.events.on(WALLET_CONNECT_CHECK_PAIRINGS) do(e: Args):
      self.setHasActivePairings(true)
      self.checkPairings()

    self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DATA_SIGNED) do(e: Args):
      let args = SharedKeycarModuleArgs(e)
      if args.uniqueIdentifier != UNIQUE_WC_SESSION_REQUEST_SIGNING_IDENTIFIER and
        args.uniqueIdentifier != UNIQUE_WC_AUTH_REQUEST_SIGNING_IDENTIFIER:
        return
      self.onDataSigned(args.keyUid, args.path, args.r, args.s, args.v, args.pin, args.uniqueIdentifier)

  proc delete*(self: Controller) =
    self.invalidateData()
    self.QObject.delete

  proc newController*(events: EventEmitter, walletAccountService: wallet_account_service.Service): Controller =
    new(result, delete)
    result.events = events
    result.walletAccountService = walletAccountService
    result.setup()

  proc invalidateData(self: Controller) =
    self.sessionRequestJson = nil
    self.txResponseDto = nil

  proc onDataSigned(self: Controller, keyUid: string, path: string, r: string, s: string, v: string, pin: string, identifier: string) =
    if keyUid.len == 0 or path.len == 0 or r.len == 0 or s.len == 0 or v.len == 0 or pin.len == 0:
      error "invalid data signed"
      return
    let signature = "0x" & r & s & v
    if identifier == UNIQUE_WC_SESSION_REQUEST_SIGNING_IDENTIFIER:
      self.finishSessionRequest(signature)
    elif identifier == UNIQUE_WC_AUTH_REQUEST_SIGNING_IDENTIFIER:
      self.finishAuthRequest(signature)
    else:
      error "Unknown identifier"

  proc sessionProposal(self: Controller, sessionProposalJson: string) {.slot.} =
    var
      supportedNamespacesJson: string
      error: string
    try:
      var res: JsonNode
      let err = backend_wallet_connect.pair(res, sessionProposalJson)
      if err.len > 0:
        raise newException(CatchableError, err)

      supportedNamespacesJson = if res.hasKey("supportedNamespaces"): $res["supportedNamespaces"] else: ""
    except Exception as e:
      error = e.msg
      error "pairing", msg=error
    self.respondSessionProposal(sessionProposalJson, supportedNamespacesJson, error)

  proc saveOrUpdateSession(self: Controller, sessionJson: string) {.slot.} =
    if not backend_wallet_connect.saveOrUpdateSession(sessionJson):
      error "Failed to save/update session"

  proc deleteSession(self: Controller, topic: string) {.slot.} =
    if not backend_wallet_connect.deleteSession(topic):
      error "Failed to delete session"

  proc getHasActivePairings*(self: Controller): bool {.slot.} =
    return self.hasActivePairings

  proc setHasActivePairings*(self: Controller, value: bool) {.slot.} =
    self.hasActivePairings = value
    self.hasActivePairingsChanged()

  QtProperty[bool] hasActivePairings:
    read = getHasActivePairings
    write = setHasActivePairings
    notify = hasActivePairingsChanged

  proc sendTransactionAndRespond(self: Controller, signature: string) =
    let finalSignature = singletonInstance.utils.removeHexPrefix(signature)
    var txResponse: JsonNode
    let err = backend_wallet.sendTransactionWithSignature(txResponse, self.txResponseDto.chainId,
      $PendingTransactionTypeDto.WalletConnectTransfer, $self.txResponseDto.txArgsJson, finalSignature)
    if err.len > 0 or txResponse.isNil:
      error "Failed to send tx"
      return
    let txHash = txResponse.getStr
    self.respondSessionRequest($self.sessionRequestJson, txHash, false)

  proc buildRawTransactionAndRespond(self: Controller, signature: string) =
    let finalSignature = singletonInstance.utils.removeHexPrefix(signature)
    var txResponse: JsonNode
    let err = backend_wallet.buildRawTransaction(txResponse, self.txResponseDto.chainId, $self.txResponseDto.txArgsJson,
      finalSignature)
    if err.len > 0:
      error "Failed to build raw tx"
      return
    let txResponseDto = txResponse.toTxResponseDto()
    self.respondSessionRequest($self.sessionRequestJson, txResponseDto.rawTx, false)

  proc finishSessionRequest(self: Controller, signature: string) =
    if signature.len == 0:
      self.respondSessionRequest($self.sessionRequestJson, "", true)
      return
    let requestMethod = getRequestMethod(self.sessionRequestJson)
    if requestMethod == RequestMethod.SendTransaction:
      self.sendTransactionAndRespond(signature)
    elif requestMethod == RequestMethod.SignTransaction:
      self.buildRawTransactionAndRespond(signature)
    elif requestMethod == RequestMethod.PersonalSign:
      self.respondSessionRequest($self.sessionRequestJson, signature, false)
    elif requestMethod == RequestMethod.EthSign:
      self.respondSessionRequest($self.sessionRequestJson, signature, false)
    elif requestMethod == RequestMethod.SignTypedData or
      requestMethod == RequestMethod.SignTypedDataV3 or
      requestMethod == RequestMethod.SignTypedDataV4:
        self.respondSessionRequest($self.sessionRequestJson, signature, false)
    else:
      error "Unknown request method"
      self.respondSessionRequest($self.sessionRequestJson, "", true)

  proc sessionRequest*(self: Controller, sessionRequestJson: string, password: string) {.slot.} =
    var signature: string
    try:
      self.invalidateData()
      self.sessionRequestJson = parseJson(sessionRequestJson)
      var sessionRes: JsonNode
      let err = backend_wallet_connect.sessionRequest(sessionRes, sessionRequestJson)
      if err.len > 0:
        raise newException(CatchableError, err)

      self.txResponseDto = sessionRes.toTxResponseDto()
      if self.txResponseDto.signOnKeycard:
        let data = SharedKeycarModuleSigningArgs(uniqueIdentifier: UNIQUE_WC_SESSION_REQUEST_SIGNING_IDENTIFIER,
          keyUid: self.txResponseDto.keyUid,
          path: self.txResponseDto.addressPath,
          dataToSign: singletonInstance.utils.removeHexPrefix(self.txResponseDto.messageToSign))
        self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_SIGN_DATA, data)
        return
      else:
        let hashedPasssword = common_utils.hashPassword(password)
        var signMsgRes: JsonNode
        let err = backend_wallet.signMessage(signMsgRes,
          self.txResponseDto.messageToSign,
          self.txResponseDto.address,
          hashedPasssword)
        if err.len > 0:
          raise newException(CatchableError, err)
        signature = signMsgRes.getStr
    except Exception as e:
      error "session request", msg=e.msg
    self.finishSessionRequest(signature)

  proc getProjectId*(self: Controller): string {.slot.} =
    return constants.WALLET_CONNECT_PROJECT_ID
  QtProperty[string] projectId:
    read = getProjectId

  proc getWalletAccounts*(self: Controller): string {.slot.} =
    let jsonObj = % self.walletAccountService.getWalletAccounts()
    return $jsonObj

  proc finishAuthRequest(self: Controller, signature: string) =
    if signature.len == 0:
      self.respondAuthRequest("", true)
      return
    self.respondAuthRequest(signature, false)

  proc authRequest*(self: Controller, selectedAddress: string, authMessage: string, password: string) {.slot.} =
    var signature: string
    try:
      self.invalidateData()
      var sessionRes: JsonNode
      let err = backend_wallet_connect.authRequest(sessionRes, selectedAddress, authMessage)
      if err.len > 0:
        raise newException(CatchableError, err)

      self.txResponseDto = sessionRes.toTxResponseDto()
      if self.txResponseDto.signOnKeycard:
        let data = SharedKeycarModuleSigningArgs(uniqueIdentifier: UNIQUE_WC_AUTH_REQUEST_SIGNING_IDENTIFIER,
          keyUid: self.txResponseDto.keyUid,
          path: self.txResponseDto.addressPath,
          dataToSign: singletonInstance.utils.removeHexPrefix(self.txResponseDto.messageToSign))
        self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_SIGN_DATA, data)
        return
      else:
        let hashedPasssword = common_utils.hashPassword(password)
        var signMsgRes: JsonNode
        let err = backend_wallet.signMessage(signMsgRes,
          self.txResponseDto.messageToSign,
          self.txResponseDto.address,
          hashedPasssword)
        if err.len > 0:
          raise newException(CatchableError, err)
        signature = signMsgRes.getStr
    except Exception as e:
      error "auth request", msg=e.msg
    self.finishAuthRequest(signature)