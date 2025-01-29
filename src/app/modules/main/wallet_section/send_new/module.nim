import tables, NimQml, sequtils, sugar, strutils, chronicles, stint

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter

import app_service/common/utils
import app_service/common/wallet_constants
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/transaction/service as transaction_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycard/constants as keycard_constants
import app_service/service/transaction/dto
import app_service/service/transaction/dtoV2
import app_service/service/token/utils

export io_interface

logScope:
  topics = "wallet-send-module"

const authenticationCanceled* = "authenticationCanceled"

# Shouldn't be public ever, use only within this module.
type TmpSendTransactionDetails = object
  fromAddrPath: string
  uuid: string
  sendType: SendType
  pin: string
  password: string
  txHashBeingProcessed: string
  resolvedSignatures: TransactionsSignatures
  slippagePercentage: float

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    controller: controller.Controller
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails
    tmpKeepPinPass: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  transactionService: transaction_service.Service,
  keycardService: keycard_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.controller = controller.newController(result, events, walletAccountService,
    networkService, transactionService, keycardService)
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)

  result.moduleLoaded = false

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete
  self.controller.delete

proc clearTmpData(self: Module, keepPinPass = false) =
  if keepPinPass:
    self.tmpSendTransactionDetails = TmpSendTransactionDetails(
      sendType: self.tmpSendTransactionDetails.sendType,
      pin: self.tmpSendTransactionDetails.pin,
      password: self.tmpSendTransactionDetails.password
    )
    return
  self.tmpSendTransactionDetails = TmpSendTransactionDetails()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionSendNew", self.viewVariant)

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.sendModuleDidLoad()

proc convertTransactionPathDtoV2ToPathItem(self: Module, txPath: TransactionPathDtoV2): PathItem =
  var fromChainId = 0
  var toChainid = 0
  var fromTokenSymbol = ""
  var toTokenSymbol = ""
  if not txPath.fromChain.isNil:
    fromChainId = txPath.fromChain.chainId
  if not txPath.toChain.isNil:
    toChainId = txPath.toChain.chainId
  if not txPath.fromToken.isNil:
    fromTokenSymbol = txPath.fromToken.bySymbolModelKey()
  if not txPath.toToken.isNil:
    toTokenSymbol = txPath.toToken.bySymbolModelKey()

  result = newPathItem(
    processorName = txPath.processorName,
    fromChain = fromChainId,
    toChain = toChainId,
    fromToken = fromTokenSymbol,
    toToken = toTokenSymbol,
    amountIn = $txPath.amountIn,
    amountInLocked = txPath.amountInLocked,
    amountOut = $txPath.amountOut,
    suggestedMaxFeesPerGasLowLevel = $txPath.suggestedLevelsForMaxFeesPerGas.low,
    suggestedMaxFeesPerGasMediumLevel = $txPath.suggestedLevelsForMaxFeesPerGas.medium,
    suggestedMaxFeesPerGasHighLevel = $txPath.suggestedLevelsForMaxFeesPerGas.high,
    suggestedMinPriorityFee = $txPath.suggestedMinPriorityFee,
    suggestedMaxPriorityFee = $txPath.suggestedMaxPriorityFee,
    currentBaseFee = $txPath.currentBaseFee,
    txNonce = $txPath.txNonce,
    txMaxFeesPerGas = $txPath.txMaxFeesPerGas,
    txBaseFee = $txPath.txBaseFee,
    txPriorityFee = $txPath.txPriorityFee,
    txGasAmount = $txPath.txGasAmount,
    txBonderFees = $txPath.txBonderFees,
    txTokenFees = $txPath.txTokenFees,
    txEstimatedTime = txPath.txEstimatedTime,
    txFee = $txPath.txFee,
    txL1Fee = $txPath.txL1Fee,
    approvalRequired = txPath.approvalRequired,
    approvalAmountRequired = $txPath.approvalAmountRequired,
    approvalContractAddress = txPath.approvalContractAddress,
    approvalTxNonce = $txPath.approvalTxNonce,
    approvalMaxFeesPerGas = $txPath.approvalMaxFeesPerGas,
    approvalBaseFee = $txPath.approvalBaseFee,
    approvalPriorityFee = $txPath.approvalPriorityFee,
    approvalGasAmount = $txPath.approvalGasAmount,
    approvalEstimatedTime = txPath.approvalEstimatedTime,
    approvalFee = $txPath.approvalFee,
    approvalL1Fee = $txPath.approvalL1Fee,
    txTotalFee = $txPath.txTotalFee
    )

proc buildTransactionsFromRoute(self: Module) =
  let err = self.controller.buildTransactionsFromRoute(self.tmpSendTransactionDetails.uuid, self.tmpSendTransactionDetails.slippagePercentage)
  if err.len > 0:
    self.transactionWasSent(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = err)
    self.clearTmpData()

method authenticateAndTransfer*(self: Module, uuid: string, fromAddr: string, slippagePercentage: float) =
  self.tmpSendTransactionDetails.uuid = uuid
  self.tmpSendTransactionDetails.slippagePercentage = slippagePercentage
  self.tmpSendTransactionDetails.resolvedSignatures.clear()

  if self.tmpKeepPinPass:
    # no need to authenticate again, just send a swap tx
    self.buildTransactionsFromRoute()
    return

  let kp = self.controller.getKeypairByAccountAddress(fromAddr)
  if kp.migratedToKeycard():
    let accounts = kp.accounts.filter(acc => cmpIgnoreCase(acc.address, fromAddr) == 0)
    if accounts.len != 1:
      error "cannot resolve selected account to send from among known keypair accounts"
      return
    self.controller.authenticate(kp.keyUid)
  else:
    self.controller.authenticate()

method onUserAuthenticated*(self: Module, password: string, pin: string) =
  if password.len == 0:
    self.transactionWasSent(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = authenticationCanceled)
    self.clearTmpData()
  else:
    self.tmpSendTransactionDetails.pin = pin
    self.tmpSendTransactionDetails.password = password
    self.buildTransactionsFromRoute()

proc sendSignedTransactions*(self: Module) =
  try:
    # check if all transactions are signed
    for _, (r, s, v) in self.tmpSendTransactionDetails.resolvedSignatures.pairs:
      if r.len == 0 or s.len == 0 or v.len == 0:
        raise newException(CatchableError, "not all transactions are signed")

    let err = self.controller.sendRouterTransactionsWithSignatures(self.tmpSendTransactionDetails.uuid, self.tmpSendTransactionDetails.resolvedSignatures)
    if err.len > 0:
      raise newException(CatchableError, "sending transaction failed: " & err)
  except Exception as e:
    error "sendSignedTransactions failed: ", msg=e.msg
    self.transactionWasSent(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = e.msg)
    self.clearTmpData()

proc signOnKeycard(self: Module) =
  self.tmpSendTransactionDetails.txHashBeingProcessed = ""
  for h, (r, s, v) in self.tmpSendTransactionDetails.resolvedSignatures.pairs:
    if r.len != 0 and s.len != 0 and v.len != 0:
      continue
    self.tmpSendTransactionDetails.txHashBeingProcessed = h
    var txForKcFlow = self.tmpSendTransactionDetails.txHashBeingProcessed
    if txForKcFlow.startsWith("0x"):
      txForKcFlow = txForKcFlow[2..^1]
    self.controller.runSignFlow(self.tmpSendTransactionDetails.pin, self.tmpSendTransactionDetails.fromAddrPath, txForKcFlow)
    break
  if self.tmpSendTransactionDetails.txHashBeingProcessed.len == 0:
    self.sendSignedTransactions()

proc getRSVFromSignature(self: Module, signature: string): (string, string, string) =
  let finalSignature = singletonInstance.utils.removeHexPrefix(signature)
  if finalSignature.len != SIGNATURE_LEN:
    return ("", "", "")
  let r = finalSignature[0..63]
  let s = finalSignature[64..127]
  let v = finalSignature[128..129]
  return (r, s, v)

method prepareSignaturesForTransactions*(self:Module, txForSigning: RouterTransactionsForSigningDto) =
  var res = ""
  try:
    if txForSigning.sendDetails.uuid != self.tmpSendTransactionDetails.uuid:
      raise newException(CatchableError, "preparing signatures for transactions are not matching the initial request")
    if txForSigning.signingDetails.hashes.len == 0:
      raise newException(CatchableError, "no transaction hashes to be signed")
    if txForSigning.signingDetails.keyUid == "" or txForSigning.signingDetails.address == "" or txForSigning.signingDetails.addressPath == "":
      raise newException(CatchableError, "preparing signatures for transactions failed")

    if txForSigning.signingDetails.signOnKeycard:
      self.tmpSendTransactionDetails.fromAddrPath = txForSigning.signingDetails.addressPath
      for h in txForSigning.signingDetails.hashes:
        self.tmpSendTransactionDetails.resolvedSignatures[h] = ("", "", "")
      self.signOnKeycard()
    else:
      var finalPassword = self.tmpSendTransactionDetails.password
      if not singletonInstance.userProfile.getIsKeycardUser():
        finalPassword = hashPassword(self.tmpSendTransactionDetails.password)
      for h in txForSigning.signingDetails.hashes:
        self.tmpSendTransactionDetails.resolvedSignatures[h] = ("", "", "")
        var
          signature = ""
          err: string
        (signature, err) = self.controller.signMessage(txForSigning.signingDetails.address, finalPassword, h)
        if err.len > 0:
          raise newException(CatchableError, "signing transaction failed: " & err)
        self.tmpSendTransactionDetails.resolvedSignatures[h] = self.getRSVFromSignature(signature)
      self.sendSignedTransactions()
  except Exception as e:
    error "signMessageWithCallback failed: ", msg=e.msg
    self.transactionWasSent(uuid = txForSigning.sendDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = e.msg)
    self.clearTmpData()

method onTransactionSigned*(self: Module, keycardFlowType: string, keycardEvent: KeycardEvent) =
  if keycardFlowType != keycard_constants.ResponseTypeValueKeycardFlowResult:
    let err = "unexpected error while keycard signing transaction"
    error "error", err=err
    self.transactionWasSent(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = err)
    self.clearTmpData()
    return
  self.tmpSendTransactionDetails.resolvedSignatures[self.tmpSendTransactionDetails.txHashBeingProcessed] = (keycardEvent.txSignature.r,
    keycardEvent.txSignature.s, keycardEvent.txSignature.v)
  self.signOnKeycard()

method transactionWasSent*(self: Module, uuid: string, chainId: int = 0, approvalTx: bool = false, txHash: string = "", error: string = "") =
  self.tmpKeepPinPass = approvalTx # need to automate the swap flow with approval
  defer:
    self.clearTmpData(self.tmpKeepPinPass)
  if txHash.len == 0:
    self.view.sendTransactionSentSignal(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error)
    return
  self.view.sendTransactionSentSignal(uuid, chainId, approvalTx, txHash, error)

method suggestedRoutesReady*(self: Module, uuid: string, routes: seq[TransactionPathDtoV2], errCode: string, errDescription: string) =
  let paths = routes.map(x => self.convertTransactionPathDtoV2ToPathItem(x))
  self.view.getPathModel().setItems(paths)
  self.view.sendSuggestedRoutesReadySignal(uuid, errCode, errDescription)

method suggestedRoutes*(self: Module,
  uuid: string,
  sendType: SendType,
  chainId: int,
  accountFrom: string,
  accountTo: string,
  token: string,
  tokenIsOwnerToken: bool,
  amountIn: string,
  toToken: string = "",
  amountOut: string = "",
  extraParamsTable: Table[string, string] = initTable[string, string]()) =
  # maybe not needed
  # self.tmpSendTransactionDetails.sendType = sendType
  var lockedInAmountsTable = Table[string, string] : initTable[string, string]()
  let networks = self.controller.getCurrentNetworks()
  let disabledNetworks = networks.filter(x => x.chainId != chainId).map(x => x.chainId)
  self.controller.suggestedRoutes(
    uuid,
    sendType,
    accountFrom,
    accountTo,
    token,
    tokenIsOwnerToken,
    amountIn,
    toToken,
    amountOut,
    disabledNetworks,
    disabledNetworks,
    lockedInAmountsTable,
    extraParamsTable
  )

method stopUpdatesForSuggestedRoute*(self: Module) =
  self.controller.stopSuggestedRoutesAsyncCalculation()

method transactionSendingComplete*(self: Module, txHash: string, status: string) =
  self.view.sendtransactionSendingCompleteSignal(txHash, status)
