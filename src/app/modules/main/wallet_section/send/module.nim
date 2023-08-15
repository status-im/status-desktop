import tables, NimQml, sequtils, sugar, json, stint, strutils

import ./io_interface, ./view, ./controller, ./network_item, ./transaction_routes, ./suggested_route_item, ./suggested_route_model, ./gas_estimate_item, ./gas_fees_item, ./network_model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/currency/service as currency_service
import app_service/service/transaction/service as transaction_service
import app_service/service/network_connection/service
import app/modules/shared/wallet_utils
import app_service/service/transaction/dto
import app/modules/shared_models/currency_amount

export io_interface

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
type TmpSendTransactionDetails = object
  fromAddr: string
  toAddr: string
  tokenSymbol: string
  value: string
  paths: seq[TransactionPathDto]
  uuid: string

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails
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
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, events, walletAccountService, networkService, currencyService, transactionService)
  result.moduleLoaded = false
  result.senderCurrentAccountIndex = 0
  result.receiveCurrentAccountIndex = 0

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method convertSendToNetworkToNetworkItem(self: Module, network: SendToNetwork): NetworkItem =
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

method convertNetworkDtoToNetworkItem(self: Module, network: NetworkDto): NetworkItem =
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

method convertSuggestedFeesDtoToGasFeesItem(self: Module, gasFees: SuggestedFeesDto): GasFeesItem =
  result = newGasFeesItem(
    gasPrice = gasFees.gasPrice,
    baseFee = gasFees.baseFee,
    maxPriorityFeePerGas = gasFees.maxPriorityFeePerGas,
    maxFeePerGasL = gasFees.maxFeePerGasL,
    maxFeePerGasM = gasFees.maxFeePerGasM,
    maxFeePerGasH = gasFees.maxFeePerGasH,
    eip1559Enabled = gasFees.eip1559Enabled
    )

method convertFeesDtoToGasEstimateItem(self: Module, fees: FeesDto): GasEstimateItem =
  result = newGasEstimateItem(
    totalFeesInEth = fees.totalFeesInEth,
    totalTokenFees = fees.totalTokenFees,
    totalTime = fees.totalTime
    )

method convertTransactionPathDtoToSuggestedRouteItem(self: Module, path: TransactionPathDto): SuggestedRouteItem =
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

method refreshNetworks*(self: Module) =
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

method authenticateAndTransfer*(self: Module, from_addr: string, to_addr: string, tokenSymbol: string, value: string, uuid: string) =
  self.tmpSendTransactionDetails.fromAddr = from_addr
  self.tmpSendTransactionDetails.toAddr = to_addr
  self.tmpSendTransactionDetails.tokenSymbol = tokenSymbol
  self.tmpSendTransactionDetails.value = value
  self.tmpSendTransactionDetails.uuid = uuid

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

  ##################################
  ## Do Not Delete
  ##
  ## Once we start with signing a transactions we shold check if the address we want to send a transaction from is migrated
  ## or not. In case it's not we should just authenticate logged in user, otherwise we should use one of the keycards that
  ## address (key pair) is migrated to and sign the transaction using it.
  ##
  ## The code bellow is an example how we can achieve that in future, when we start with signing transactions.
  ##
  ## let acc = self.controller.getAccountByAddress(from_addr)
  ## if acc.isNil:
  ##   echo "error: selected account to send a transaction from is not known"
  ##   return
  ## let keyPair = self.controller.getKeycardsWithSameKeyUid(acc.keyUid)
  ## if keyPair.len == 0:
  ##   self.controller.authenticateUser()
  ## else:
  ##   self.controller.authenticateUser(acc.keyUid, acc.path)
  ##
  ##################################

method onUserAuthenticated*(self: Module, password: string) =
  if password.len == 0:
    self.view.transactionWasSent(chainId = 0, txHash = "", uuid = self.tmpSendTransactionDetails.uuid, error = cancelledRequest)
  else:
    self.controller.transfer(
      self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr,
      self.tmpSendTransactionDetails.tokenSymbol, self.tmpSendTransactionDetails.value, self.tmpSendTransactionDetails.uuid,
      self.tmpSendTransactionDetails.paths, password
    )

method transactionWasSent*(self: Module, chainId: int, txHash, uuid, error: string) =
  self.view.transactionWasSent(chainId, txHash, uuid, error)

method suggestedRoutes*(self: Module, account: string, amount: UInt256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[int], sendType: int, lockedInAmounts: string): string =
  return self.controller.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)

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

method setSelectedSenderAccountIndex*(self: Module, index: int) =
  self.senderCurrentAccountIndex = index

method setSelectedReceiveAccountIndex*(self: Module, index: int) =
  self.receiveCurrentAccountIndex = index
