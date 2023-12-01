import tables, NimQml, sequtils, sugar, stint, strutils, chronicles

import ./io_interface, ./view, ./controller, ./network_item, ./transaction_routes, ./suggested_route_item, ./suggested_route_model, ./gas_estimate_item, ./gas_fees_item, ./network_model
import ../io_interface as delegate_interface
import app/global/global_singleton
import app/core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/currency/service as currency_service
import app_service/service/transaction/service as transaction_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycard/constants as keycard_constants
import app/modules/shared/wallet_utils
import app_service/service/transaction/dto
import app/modules/shared_models/currency_amount

import app/modules/shared_modules/collectibles/controller as collectiblesc
import app/modules/shared_models/collectibles_model as collectibles
import app/modules/shared_models/collectibles_nested_model as nested_collectibles
import backend/collectibles as backend_collectibles

export io_interface

logScope:
  topics = "wallet-send-module"

const authenticationCanceled* = "authenticationCanceled"

# Shouldn't be public ever, use only within this module.
type TmpSendTransactionDetails = object
  fromAddr: string
  fromAddrPath: string
  toAddr: string
  tokenSymbol: string
  value: string
  paths: seq[TransactionPathDto]
  uuid: string
  sendType: SendType
  resolvedSignatures: TransactionsSignatures
  tokenName: string
  isOwnerToken: bool

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: controller.Controller
    # Get the list of owned collectibles by the currently selected account
    collectiblesController: collectiblesc.Controller
    nestedCollectiblesModel: nested_collectibles.Model
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails
    tmpPin: string
    tmpTxHashBeingProcessed: string
    senderCurrentAccountIndex: int
    # To-do we should create a dedicated module Receive
    receiveCurrentAccountIndex: int

# Forward declaration
method getTokenBalanceOnChain*(self: Module, address: string, chainId: int, symbol: string): CurrencyAmount

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
  result.collectiblesController = collectiblesc.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.WalletSend),
    autofetch = true,
    networkService = networkService,
    events = events
  )
  result.nestedCollectiblesModel = nested_collectibles.newModel(result.collectiblesController.getModel())
  result.view = newView(result)

  result.moduleLoaded = false
  result.senderCurrentAccountIndex = 0
  result.receiveCurrentAccountIndex = 0

method delete*(self: Module) =
  self.view.delete
  self.controller.delete
  self.nestedCollectiblesModel.delete
  self.collectiblesController.delete

proc convertSendToNetworkToNetworkItem(self: Module, network: SendToNetwork): NetworkItem =
  result = initNetworkItem(
      network.chainId,
      network.chainName,
      network.iconUrl,
      chainColor = "",
      shortName = "",
      layer = 0,
      nativeCurrencyDecimals = 0,
      nativeCurrencyName = "",
      nativeCurrencySymbol = "",
      true,
      true,
      true,
      newCurrencyAmount(),
      false,
      lockedAmount = "",
      amountIn = "",
      $network.amountOut)

proc convertNetworkDtoToNetworkItem(self: Module, network: NetworkDto): NetworkItem =
  result = initNetworkItem(
      network.chainId,
      network.chainName,
      network.iconUrl,
      network.chainColor,
      network.shortName,
      network.layer,
      network.nativeCurrencyDecimals,
      network.nativeCurrencyName,
      network.nativeCurrencySymbol,
      true,
      false,
      true,
      self.getTokenBalanceOnChain(self.view.getSelectedSenderAccountAddress(), network.chainId, self.view.getSelectedAssetSymbol())
      )

proc convertSuggestedFeesDtoToGasFeesItem(self: Module, gasFees: SuggestedFeesDto): GasFeesItem =
  result = newGasFeesItem(
    gasPrice = gasFees.gasPrice,
    baseFee = gasFees.baseFee,
    maxPriorityFeePerGas = gasFees.maxPriorityFeePerGas,
    maxFeePerGasL = gasFees.maxFeePerGasL,
    maxFeePerGasM = gasFees.maxFeePerGasM,
    maxFeePerGasH = gasFees.maxFeePerGasH,
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
    approvalGasFees = path.approvalGasFees
    )

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  let currency = self.controller.getCurrentCurrency()
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  let chainIds = self.controller.getChainIds()
  let areTestNetworksEnabled = self.controller.areTestNetworksEnabled()

  let items = walletAccounts.map(w => (block:
    let tokens = self.controller.getTokensByAddress(w.address)
    let tokenFormats = collect(initTable()):
      for t in tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}

    let currencyBalance = self.controller.getCurrencyBalance(w.address, enabledChainIds, currency)
    walletAccountToWalletSendAccountItem(
      w,
      tokens,
      chainIds,
      enabledChainIds,
      currency,
      currencyBalance,
      currencyFormat,
      tokenFormats,
      areTestNetworksEnabled,
    )
  ))

  self.view.setItems(items)
  self.view.switchSenderAccount(self.senderCurrentAccountIndex)
  self.view.switchReceiveAccount(self.receiveCurrentAccountIndex)

proc refreshNetworks*(self: Module) =
  let networks = self.controller.getNetworks()
  let fromNetworks = networks.map(x => self.convertNetworkDtoToNetworkItem(x))
  let toNetworks = networks.map(x => self.convertNetworkDtoToNetworkItem(x))
  self.view.setNetworkItems(fromNetworks, toNetworks)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionSend", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()
    self.refreshNetworks()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_PREFERRED_SHARING_CHAINS_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_HIDDEN_UPDATED) do(e: Args):
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.refreshNetworks()
  self.moduleLoaded = true
  self.delegate.sendModuleDidLoad()

method getTokenBalanceOnChain*(self: Module, address: string, chainId: int, symbol: string): CurrencyAmount =
  return self.controller.getTokenBalanceOnChain(address, chainId, symbol)

method authenticateAndTransfer*(self: Module, fromAddr: string, toAddr: string, tokenSymbol: string, value: string, uuid: string, sendType: SendType, selectedTokenName: string, selectedTokenIsOwnerToken: bool) =
  self.tmpSendTransactionDetails.fromAddr = fromAddr
  self.tmpSendTransactionDetails.toAddr = toAddr
  self.tmpSendTransactionDetails.tokenSymbol = tokenSymbol
  self.tmpSendTransactionDetails.value = value
  self.tmpSendTransactionDetails.uuid = uuid
  self.tmpSendTransactionDetails.sendType = sendType
  self.tmpSendTransactionDetails.fromAddrPath = ""
  self.tmpSendTransactionDetails.resolvedSignatures.clear()
  self.tmpSendTransactionDetails.tokenName = selectedTokenName
  self.tmpSendTransactionDetails.isOwnerToken = selectedTokenIsOwnerToken

  let kp = self.controller.getKeypairByAccountAddress(fromAddr)
  if kp.migratedToKeycard():
    let accounts = kp.accounts.filter(acc => cmpIgnoreCase(acc.address, fromAddr) == 0)
    if accounts.len != 1:
      error "cannot resolve selected account to send from among known keypair accounts"
      return
    self.tmpSendTransactionDetails.fromAddrPath = accounts[0].path
    self.controller.authenticate(kp.keyUid)
  else:
    self.controller.authenticate()

method onUserAuthenticated*(self: Module, password: string, pin: string) =
  if password.len == 0:
    self.transactionWasSent(chainId = 0, txHash = "", uuid = self.tmpSendTransactionDetails.uuid, error = authenticationCanceled)
  else:
    self.tmpPin = pin
    let doHashing = self.tmpPin.len == 0
    let usePassword = self.tmpSendTransactionDetails.fromAddrPath.len == 0
    self.controller.transfer(
      self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr,
      self.tmpSendTransactionDetails.tokenSymbol, self.tmpSendTransactionDetails.value, self.tmpSendTransactionDetails.uuid,
      self.tmpSendTransactionDetails.paths, password, self.tmpSendTransactionDetails.sendType, usePassword, doHashing,
      self.tmpSendTransactionDetails.tokenName, self.tmpSendTransactionDetails.isOwnerToken
    )

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
    self.controller.proceedWithTransactionsSignatures(self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr,
      self.tmpSendTransactionDetails.uuid, self.tmpSendTransactionDetails.resolvedSignatures, self.tmpSendTransactionDetails.paths)

method prepareSignaturesForTransactions*(self: Module, txHashes: seq[string]) =
  if txHashes.len == 0:
    error "no transaction hashes to be signed"
    return
  for h in txHashes:
    self.tmpSendTransactionDetails.resolvedSignatures[h] = ("", "", "")
  self.signOnKeycard()

method onTransactionSigned*(self: Module, keycardFlowType: string, keycardEvent: KeycardEvent) =
  if keycardFlowType != keycard_constants.ResponseTypeValueKeycardFlowResult:
    error "unexpected error while keycard signing transaction"
    return
  self.tmpSendTransactionDetails.resolvedSignatures[self.tmpTxHashBeingProcessed] = (keycardEvent.txSignature.r,
    keycardEvent.txSignature.s, keycardEvent.txSignature.v)
  self.signOnKeycard()

method transactionWasSent*(self: Module, chainId: int, txHash, uuid, error: string) =
  if txHash.len == 0:
    self.view.sendTransactionSentSignal(chainId = 0, txHash = "", uuid = self.tmpSendTransactionDetails.uuid, error)
    return
  self.view.sendTransactionSentSignal(chainId, txHash, uuid, error)

method suggestedRoutes*(self: Module, accountFrom: string, accountTo: string, amount: UInt256, token: string, disabledFromChainIDs,
  disabledToChainIDs, preferredChainIDs: seq[int], sendType: SendType, lockedInAmounts: string): string =
  return self.controller.suggestedRoutes(accountFrom, accountTo, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)

method suggestedRoutesReady*(self: Module, suggestedRoutes: SuggestedRoutesDto) =
  self.tmpSendTransactionDetails.paths = suggestedRoutes.best
  let paths = suggestedRoutes.best.map(x => self.convertTransactionPathDtoToSuggestedRouteItem(x))
  let suggestedRouteModel = newSuggestedRouteModel()
  suggestedRouteModel.setItems(paths)
  let gasTimeEstimate = self.convertFeesDtoToGasEstimateItem(suggestedRoutes.gasTimeEstimate)
  let networks = suggestedRoutes.toNetworks.map(x => self.convertSendToNetworkToNetworkItem(x))
  let toNetworksModel = newNetworkModel()
  toNetworksModel.setItems(networks)
  self.view.updatedNetworksWithRoutes(paths, gasTimeEstimate.getTotalFeesInEth())
  let transactionRoutes = newTransactionRoutes(
    suggestedRoutes = suggestedRouteModel,
    gasTimeEstimate = gasTimeEstimate,
    amountToReceive = suggestedRoutes.amountToReceive,
    toNetworksModel = toNetworksModel)
  self.view.setTransactionRoute(transactionRoutes)

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  if addresses.len == 0:
    return
  self.view.switchSenderAccountByAddress(addresses[0])
  self.view.switchReceiveAccountByAddress(addresses[0])

proc updateCollectiblesFilter*(self: Module) =
  let addresses = @[self.view.getSenderAddressByIndex(self.senderCurrentAccountIndex)]
  let chainIds = self.controller.getChainIds()
  self.collectiblesController.setFilterAddressesAndChains(addresses, chainIds)

method setSelectedSenderAccountIndex*(self: Module, index: int) =
  self.senderCurrentAccountIndex = index
  self.updateCollectiblesFilter()

method setSelectedReceiveAccountIndex*(self: Module, index: int) =
  self.receiveCurrentAccountIndex = index

method getCollectiblesModel*(self: Module): collectibles.Model =
  return self.collectiblesController.getModel()

method getNestedCollectiblesModel*(self: Module): nested_collectibles.Model =
  return self.nestedCollectiblesModel

method splitAndFormatAddressPrefix*(self: Module, text : string, updateInStore: bool): string {.slot.} =
  var tempPreferredChains: seq[int]
  var chainFound = false
  var editedText = ""

  for word in plainText(text).split(':'):
    if word.startsWith("0x"):
      editedText = editedText & word
    else:
      let chainColor = self.view.getNetworkColor(word)
      if not chainColor.isEmptyOrWhitespace():
        chainFound = true
        tempPreferredChains.add(self.view.getNetworkChainId(word))
        editedText = editedText & "<span style='color: " & chainColor & "'>" & word & "</span>" & ":"

  if updateInStore:
    if not chainFound:
      self.view.updateRoutePreferredChains(self.view.getLayer1NetworkChainId())
    else:
      self.view.updateRoutePreferredChains(tempPreferredChains.join(":"))

  editedText = "<a><p>" & editedText & "</a></p>"
  return editedText
