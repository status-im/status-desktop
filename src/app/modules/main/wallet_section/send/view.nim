import NimQml, sequtils, strutils, stint, sugar

import ./io_interface, ./accounts_model, ./account_item, ./network_model, ./network_item, ./suggested_route_item, ./transaction_routes
import app/modules/shared_models/token_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      accounts: AccountsModel
      # this one doesn't include watch accounts and its what the user switches when using the sendModal
      senderAccounts: AccountsModel
      # for send modal
      selectedSenderAccount: AccountItem
      fromNetworksModel: NetworkModel
      toNetworksModel: NetworkModel
      transactionRoutes: TransactionRoutes
      selectedAssetSymbol: string
      showUnPreferredChains: bool
      # for receive modal
      selectedReceiveAccount: AccountItem

  # Forward declaration
  proc updateNetworksDisabledChains(self: View)
  proc updateNetworksTokenBalance(self: View)

  proc delete*(self: View) =
    self.accounts.delete
    self.senderAccounts.delete
    self.selectedSenderAccount.delete
    self.fromNetworksModel.delete
    self.toNetworksModel.delete
    self.transactionRoutes.delete
    self.selectedReceiveAccount.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.accounts = newAccountsModel()
    result.senderAccounts = newAccountsModel()
    result.fromNetworksModel = newNetworkModel()
    result.toNetworksModel = newNetworkModel()
    result.transactionRoutes = newTransactionRoutes()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc accountsChanged*(self: View) {.signal.}
  proc getAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.accounts)
  QtProperty[QVariant] accounts:
    read = getAccounts
    notify = accountsChanged

  proc senderAccountsChanged*(self: View) {.signal.}
  proc getSenderAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.senderAccounts)
  QtProperty[QVariant] senderAccounts:
    read = getSenderAccounts
    notify = senderAccountsChanged

  proc selectedSenderAccountChanged*(self: View) {.signal.}
  proc getSelectedSenderAccount(self: View): QVariant {.slot.} =
    return newQVariant(self.selectedSenderAccount)
  proc setSelectedSenderAccount*(self: View, account: AccountItem) =
    self.selectedSenderAccount = account
    self.updateNetworksTokenBalance()
    self.selectedSenderAccountChanged()
  QtProperty[QVariant] selectedSenderAccount:
    read = getSelectedSenderAccount
    notify = selectedSenderAccountChanged

  proc selectedReceiveAccountChanged*(self: View) {.signal.}
  proc getSelectedReceiveAccount(self: View): QVariant {.slot.} =
    return newQVariant(self.selectedReceiveAccount)
  proc setSelectetReceiveAccount*(self: View, account: AccountItem) =
    self.selectedReceiveAccount = account
    self.selectedReceiveAccountChanged()
  QtProperty[QVariant] selectedReceiveAccount:
    read = getSelectedReceiveAccount
    notify = selectedReceiveAccountChanged

  proc fromNetworksModelChanged*(self: View) {.signal.}
  proc getFromNetworksModel(self: View): QVariant {.slot.} =
    return newQVariant(self.fromNetworksModel)
  QtProperty[QVariant] fromNetworksModel:
    read = getFromNetworksModel
    notify = fromNetworksModelChanged

  proc toNetworksModelChanged*(self: View) {.signal.}
  proc getToNetworksModel(self: View): QVariant {.slot.} =
    return newQVariant(self.toNetworksModel)
  QtProperty[QVariant] toNetworksModel:
    read = getToNetworksModel
    notify = toNetworksModelChanged

  proc selectedAssetSymbolChanged*(self: View) {.signal.}
  proc getSelectedAssetSymbol*(self: View): string {.slot.} =
    return self.selectedAssetSymbol
  proc setSelectedAssetSymbol(self: View, symbol: string) {.slot.} =
    self.selectedAssetSymbol = symbol
    self.updateNetworksTokenBalance()
    self.selectedAssetSymbolChanged()
  QtProperty[string] selectedAssetSymbol:
    write = setSelectedAssetSymbol
    read = getSelectedAssetSymbol
    notify = selectedAssetSymbolChanged

  proc showUnPreferredChainsChanged*(self: View) {.signal.}
  proc getShowUnPreferredChains(self: View): bool {.slot.} =
    return self.showUnPreferredChains
  proc toggleShowUnPreferredChains*(self: View) {.slot.} =
    self.showUnPreferredChains = not self.showUnPreferredChains
    self.updateNetworksDisabledChains()
    self.showUnPreferredChainsChanged()
  QtProperty[bool] showUnPreferredChains:
    read = getShowUnPreferredChains
    notify = showUnPreferredChainsChanged

  proc updateNetworksDisabledChains(self: View) =
    # if the setting to show unpreferred chains is toggled, add all unpreferred chains to disabled chains list
    if not self.showUnPreferredChains:
      self.toNetworksModel.disableUnpreferredChains()
    else:
      self.toNetworksModel.enableUnpreferredChains()

  proc updateNetworksTokenBalance(self: View) =
    for chainId in self.toNetworksModel.getAllNetworksChainIds():
      self.fromNetworksModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalanceOnChain(self.selectedSenderAccount.address(), chainId, self.selectedAssetSymbol))
      self.toNetworksModel.updateTokenBalanceForSymbol(chainId, self.delegate.getTokenBalanceOnChain(self.selectedSenderAccount.address(), chainId, self.selectedAssetSymbol))

  proc setItems*(self: View, items: seq[AccountItem]) =
    self.accounts.setItems(items)
    self.accountsChanged()

    # need to remove watch only accounts as a user cant send a tx with a watch only account
    self.senderAccounts.setItems(items.filter(a => a.walletType() != WalletTypeWatch))
    self.senderAccountsChanged()

  proc setNetworkItems*(self: View, fromNetworks: seq[NetworkItem], toNetworks: seq[NetworkItem]) =
    self.fromNetworksModel.setItems(fromNetworks)
    self.toNetworksModel.setItems(toNetworks)

  proc transactionSent*(self: View, chainId: int, txHash: string, uuid: string, error: string) {.signal.}

  proc transactionWasSent*(self: View, chainId: int, txHash: string, uuid: string, error: string) {.slot} =
    self.transactionSent(chainId, txHash, uuid, error)

  proc authenticateAndTransfer*(self: View, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, uuid: string) {.slot.} =
      self.delegate.authenticateAndTransfer(from_addr, to_addr, tokenSymbol, value, uuid)

  proc suggestedRoutesReady*(self: View, suggestedRoutes: QVariant) {.signal.}
  proc setTransactionRoute*(self: View, routes: TransactionRoutes) =
      self.transactionRoutes = routes
      self.suggestedRoutesReady(newQVariant(self.transactionRoutes))
  proc suggestedRoutes*(self: View, amount: string, sendType: int): string {.slot.} =
    self.fromNetworksModel.reset()
    self.toNetworksModel.reset()
    var parsedAmount = stint.u256("0")
    try:
      parsedAmount = fromHex(Stuint[256], amount)
    except Exception as e:
      discard

    return self.delegate.suggestedRoutes(self.selectedSenderAccount.address(),
      parsedAmount, self.selectedAssetSymbol, self.fromNetworksModel.getDisabledNetworkChainIds(),
      self.toNetworksModel.getDisabledNetworkChainIds(), self.toNetworksModel.getPreferredNetworkChainIds(), sendType,  self.fromNetworksModel.getLockedChainIds())

  proc switchSenderAccountByAddress*(self: View, address: string) =
    let (account, index) = self.senderAccounts.getItemByAddress(address)
    self.setSelectedSenderAccount(account)
    self.delegate.setSelectedSenderAccountIndex(index)

  proc switchReceiveAccountByAddress*(self: View, address: string) =
    let (account, index) = self.accounts.getItemByAddress(address)
    self.setSelectetReceiveAccount(account)
    self.delegate.setSelectedReceiveAccountIndex(index)

  proc switchSenderAccount*(self: View, index: int) {.slot.} =
    var account = self.senderAccounts.getItemByIndex(index)
    var idx = index
    if account.isNil:
      account = self.senderAccounts.getItemByIndex(0)
      idx = 0

    self.setSelectedSenderAccount(account)
    self.delegate.setSelectedSenderAccountIndex(idx)

  proc switchReceiveAccount*(self: View, index: int) {.slot.} =
    var account = self.accounts.getItemByIndex(index)
    var idx = index
    if account.isNil:
      account = self.accounts.getItemByIndex(0)
      idx = 0

    self.setSelectetReceiveAccount(account)
    self.delegate.setSelectedReceiveAccountIndex(idx)

  proc updatePreferredChains*(self: View, chainIds: string) {.slot.} =
    self.toNetworksModel.updatePreferredChains(chainIds)

  proc getSelectedSenderAccountAddress*(self: View): string =
    return self.selectedSenderAccount.address()

  proc updatedNetworksWithRoutes*(self: View, paths: seq[SuggestedRouteItem], totalFeesInEth: float) =
    self.fromNetworksModel.reset()
    self.toNetworksModel.reset()
    for path in paths:
      let fromChainId = path.getfromNetwork()
      let hasGas = self.selectedSenderAccount.getAssets().hasGas(fromChainId, self.fromNetworksModel.getNetworkNativeGasSymbol(fromChainId), totalFeesInEth)
      self.fromNetworksModel.updateFromNetworks(path, hasGas)
      self.toNetworksModel.updateToNetworks(path)

  proc resetStoredProperties*(self: View) {.slot.} =
    self.fromNetworksModel.reset()
    self.toNetworksModel.reset()
    self.transactionRoutes = newTransactionRoutes()
    self.selectedAssetSymbol = ""
    self.showUnPreferredChains = false
