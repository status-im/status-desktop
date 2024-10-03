import tables, NimQml, sequtils, sugar, stint, strutils, chronicles

import ./io_interface, ./view, ./controller, ./network_route_item, ./transaction_routes, ./suggested_route_item, ./suggested_route_model, ./gas_estimate_item, ./gas_fees_item, ./network_route_model
import ../io_interface as delegate_interface
import app/global/global_singleton
import app/global/utils
import app/core/eventemitter
import app_service/common/utils
import app_service/common/wallet_constants
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/currency/service as currency_service
import app_service/service/transaction/service as transaction_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycard/constants as keycard_constants
import app_service/service/transaction/dto
import app/modules/shared_models/currency_amount
import app_service/service/network/network_item as network_service_item

export io_interface

logScope:
  topics = "wallet-send-module"

const authenticationCanceled* = "authenticationCanceled"

# Shouldn't be public ever, use only within this module.
type TmpSendTransactionDetails = object
  fromAddr: string
  fromAddrPath: string
  toAddr: string
  assetKey: string
  toAssetKey: string
  paths: seq[TransactionPathDto]
  uuid: string
  sendType: SendType
  resolvedSignatures: TransactionsSignatures
  tokenName: string
  isOwnerToken: bool
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
    tmpPin: string
    tmpPassword: string
    tmpTxHashBeingProcessed: string

# Forward declaration
method getTokenBalance*(self: Module, address: string, chainId: int, tokensKey: string): CurrencyAmount

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
  keycardService: keycard_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.controller = controller.newController(result, events, walletAccountService, networkService, currencyService,
    transactionService, keycardService)
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)

  result.moduleLoaded = false

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete
  self.controller.delete

proc clearTmpData(self: Module) =
  self.tmpPin = ""
  self.tmpPassword = ""
  self.tmpTxHashBeingProcessed = ""
  self.tmpSendTransactionDetails = TmpSendTransactionDetails()
  writeStackTrace()

proc convertSendToNetworkToNetworkItem(self: Module, network: SendToNetwork): NetworkRouteItem =
  result = initNetworkRouteItem(
      network.chainId,
      layer = 0,
      true,
      true,
      true,
      newCurrencyAmount(),
      false,
      lockedAmount = "",
      amountIn = "",
      $network.amountOut)

proc convertNetworkDtoToNetworkRouteItem(self: Module, network: network_service_item.NetworkItem): NetworkRouteItem =
  result = initNetworkRouteItem(
      network.chainId,
      network.layer,
      true,
      false,
      true,
      self.getTokenBalance(self.view.getSelectedSenderAccountAddress(), network.chainId, self.view.getSelectedAssetKey())
      )

proc convertSuggestedFeesDtoToGasFeesItem(self: Module, gasFees: SuggestedFeesDto): GasFeesItem =
  result = newGasFeesItem(
    gasPrice = gasFees.gasPrice,
    baseFee = gasFees.baseFee,
    maxPriorityFeePerGas = gasFees.maxPriorityFeePerGas,
    maxFeePerGasL = gasFees.maxFeePerGasL,
    maxFeePerGasM = gasFees.maxFeePerGasM,
    maxFeePerGasH = gasFees.maxFeePerGasH,
    l1GasFee = gasFees.l1GasFee,
    eip1559Enabled = gasFees.eip1559Enabled
    )

proc convertFeesDtoToGasEstimateItem(self: Module, fees: FeesDto): GasEstimateItem =
  result = newGasEstimateItem(
    totalFeesInEth = fees.totalFeesInEth,
    totalTokenFees = fees.totalTokenFees,
    totalTime = fees.totalTime
    )

proc convertTransactionPathDtoToSuggestedRouteItem(self: Module, path: TransactionPathDto): SuggestedRouteItem =
  result = newSuggestedRouteItem(
    bridgeName = path.bridgeName,
    fromNetwork = path.fromNetwork.chainId,
    toNetwork = path.toNetwork.chainId,
    maxAmountIn = $path.maxAmountIn,
    amountIn = $path.amountIn,
    amountOut = $path.amountOut,
    gasAmount = $path.gasAmount,
    gasFees = self.convertSuggestedFeesDtoToGasFeesItem(path.gasFees),
    tokenFees = path.tokenFees,
    cost = path.cost,
    estimatedTime = path.estimatedTime,
    amountInLocked = path.amountInLocked,
    isFirstSimpleTx = path.isFirstSimpleTx,
    isFirstBridgeTx = path.isFirstBridgeTx,
    approvalRequired = path.approvalRequired,
    approvalGasFees = path.approvalGasFees,
    approvalAmountRequired = $path.approvalAmountRequired,
    approvalContractAddress = path.approvalContractAddress
    )

proc refreshNetworks*(self: Module) =
  let networks = self.controller.getCurrentNetworks()
  let fromNetworks = networks.map(x => self.convertNetworkDtoToNetworkRouteItem(x))
  let toNetworks = networks.map(x => self.convertNetworkDtoToNetworkRouteItem(x))
  self.view.setNetworkItems(fromNetworks, toNetworks)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionSend", self.viewVariant)

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshNetworks()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshNetworks()
  self.moduleLoaded = true
  self.delegate.sendModuleDidLoad()

method getTokenBalance*(self: Module, address: string, chainId: int, tokensKey: string): CurrencyAmount =
  return self.controller.getTokenBalance(address, chainId, tokensKey)

method getNetworkItem*(self: Module, chainId: int): network_service_item.NetworkItem =
  let networks = self.controller.getCurrentNetworks().filter(x => x.chainId == chainId)
  if networks.len == 0:
    return nil
  return networks[0]

method authenticateAndTransferV2*(self: Module, fromAddr: string, uuid: string,  slippagePercentage: float) =
  self.tmpSendTransactionDetails.uuid = uuid
  self.tmpSendTransactionDetails.slippagePercentage = slippagePercentage
  self.tmpSendTransactionDetails.resolvedSignatures.clear()

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
    self.tmpPin = pin
    self.tmpPassword = password
    let err = self.controller.buildTransactionsFromRoute(self.tmpSendTransactionDetails.uuid, self.tmpSendTransactionDetails.slippagePercentage)
    if err.len > 0:
      self.transactionWasSent(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error = err)
      self.clearTmpData()

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
  self.tmpTxHashBeingProcessed = ""
  for h, (r, s, v) in self.tmpSendTransactionDetails.resolvedSignatures.pairs:
    if r.len != 0 and s.len != 0 and v.len != 0:
      continue
    self.tmpTxHashBeingProcessed = h
    var txForKcFlow = self.tmpTxHashBeingProcessed
    if txForKcFlow.startsWith("0x"):
      txForKcFlow = txForKcFlow[2..^1]
    self.controller.runSignFlow(self.tmpPin, self.tmpSendTransactionDetails.fromAddrPath, txForKcFlow)
    break
  if self.tmpTxHashBeingProcessed.len == 0:
    self.sendSignedTransactions()
    self.clearTmpData()

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
      let finalPassword = hashPassword(self.tmpPassword)
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
  self.tmpSendTransactionDetails.resolvedSignatures[self.tmpTxHashBeingProcessed] = (keycardEvent.txSignature.r,
    keycardEvent.txSignature.s, keycardEvent.txSignature.v)
  self.signOnKeycard()

method transactionWasSent*(self: Module, uuid: string, chainId: int = 0, approvalTx: bool = false, txHash: string = "", error: string = "") =
  if txHash.len == 0:
    self.view.sendTransactionSentSignal(uuid = self.tmpSendTransactionDetails.uuid, chainId = 0, approvalTx = false, txHash = "", error)
    return
  self.view.sendTransactionSentSignal(uuid, chainId, approvalTx, txHash, error)

method suggestedRoutesReady*(self: Module, uuid: string, suggestedRoutes: SuggestedRoutesDto, errCode: string, errDescription: string) =
  self.tmpSendTransactionDetails.paths = suggestedRoutes.best
  self.tmpSendTransactionDetails.slippagePercentage = 0
  let paths = suggestedRoutes.best.map(x => self.convertTransactionPathDtoToSuggestedRouteItem(x))
  let suggestedRouteModel = newSuggestedRouteModel()
  suggestedRouteModel.setItems(paths)
  let gasTimeEstimate = self.convertFeesDtoToGasEstimateItem(suggestedRoutes.gasTimeEstimate)
  let networks = suggestedRoutes.toNetworks.map(x => self.convertSendToNetworkToNetworkItem(x))
  let toNetworksRouteModel = newNetworkRouteModel()
  toNetworksRouteModel.setItems(networks)
  self.view.updatedNetworksWithRoutes(paths, self.controller.getChainsWithNoGasFromError(errCode, errDescription))
  let transactionRoutes = newTransactionRoutes(
    uuid = uuid,
    suggestedRoutes = suggestedRouteModel,
    gasTimeEstimate = gasTimeEstimate,
    amountToReceive = suggestedRoutes.amountToReceive,
    toNetworksRouteModel = toNetworksRouteModel,
    rawPaths = suggestedRoutes.rawBest)
  self.view.setTransactionRoute(transactionRoutes, errCode, errDescription)

method suggestedRoutes*(self: Module,
  uuid: string,
  sendType: SendType,
  accountFrom: string,
  accountTo: string,
  token: string,
  tokenIsOwnerToken: bool,
  amountIn: string,
  toToken: string = "",
  amountOut: string = "",
  disabledFromChainIDs: seq[int] = @[],
  disabledToChainIDs: seq[int] = @[],
  lockedInAmounts: Table[string, string] = initTable[string, string](),
  extraParamsTable: Table[string, string] = initTable[string, string]()) =
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
    disabledFromChainIDs,
    disabledToChainIDs,
    lockedInAmounts,
    extraParamsTable
  )

method stopUpdatesForSuggestedRoute*(self: Module) =
  self.controller.stopSuggestedRoutesAsyncCalculation()

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int], isDirty: bool) =
  if not isDirty or addresses.len == 0:
    return
  self.view.setSenderAccount(addresses[0])
  self.view.setReceiverAccount(addresses[0])

proc getNetworkColor(self: Module, shortName: string): string =
  let networks = self.controller.getCurrentNetworks()
  for network in networks:
    if cmpIgnoreCase(network.shortName, shortName) == 0:
      return network.chainColor
  return ""

proc getLayer1NetworkChainId*(self: Module): int =
  let networks = self.controller.getCurrentNetworks()
  for network in networks:
    if network.layer == NETWORK_LAYER_1:
      return network.chainId
  return 0

method getNetworkChainId*(self: Module, shortName: string): int =
  let networks = self.controller.getCurrentNetworks()
  for network in networks:
    if cmpIgnoreCase(network.shortName, shortName) == 0:
      return network.chainId
  return 0

method splitAndFormatAddressPrefix*(self: Module, text : string, updateInStore: bool): string {.slot.} =
  var tempPreferredChains: seq[int]
  var chainFound = false
  var editedText = ""

  for word in plainText(text).split(':'):
    if word.startsWith("0x"):
      editedText = editedText & word
    else:
      let chainColor = self.getNetworkColor(word)
      if not chainColor.isEmptyOrWhitespace():
        chainFound = true
        tempPreferredChains.add(self.getNetworkChainId(word))
        editedText = editedText & "<span style='color: " & chainColor & "'>" & word & "</span>" & ":"

  if updateInStore:
    if not chainFound:
      self.view.updateRoutePreferredChains($self.getLayer1NetworkChainId())
    else:
      self.view.updateRoutePreferredChains(tempPreferredChains.join(":"))

  editedText = "<a><p>" & editedText & "</a></p>"
  return editedText

method transactionSendingComplete*(self: Module, txHash: string, status: string) =
  self.view.sendtransactionSendingCompleteSignal(txHash, status)
