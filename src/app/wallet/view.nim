import NimQml, Tables, strformat, strutils, chronicles
import ../../status/[status, wallet]
import views/[asset_list, account_list, account_item, transaction_list, collectibles_list]

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      currentCollectiblesList*: CollectiblesList
      currentAccount: AccountItemView
      currentTransactions: TransactionList
      status: Status
      totalFiatBalance: string

  proc delete(self: WalletView) =
    self.accounts.delete
    self.currentAssetList.delete
    self.currentAccount.delete
    self.currentTransactions.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = newAccountItemView()
    result.currentAssetList = newAssetList()
    result.currentTransactions = newTransactionList()
    result.currentCollectiblesList = newCollectiblesList()
    result.totalFiatBalance = ""
    result.setup

  proc currentAccountChanged*(self: WalletView) {.signal.}

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset])

  proc currentCollectiblesListChanged*(self: WalletView) {.signal.}

  proc getCurrentCollectiblesList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentCollectiblesList)

  proc setCurrentCollectiblesList*(self: WalletView, collectibles: seq[Collectible]) =
    self.currentCollectiblesList.setNewData(collectibles)
    self.currentCollectiblesListChanged()

  QtProperty[QVariant] collectibles:
    read = getCurrentCollectiblesList
    write = setCurrentCollectiblesList
    notify = currentCollectiblesListChanged

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if(self.accounts.rowCount() == 0): return

    let selectedAccount = self.accounts.getAccount(index)
    if self.currentAccount.address == selectedAccount.address: return
    self.currentAccount.setAccountItem(selectedAccount)
    self.currentAccountChanged()
    self.setCurrentAssetList(selectedAccount.assetList)
    self.setCurrentCollectiblesList(selectedAccount.collectibles)

  proc getCurrentAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccountByIndex
    notify = currentAccountChanged

  proc currentAssetListChanged*(self: WalletView) {.signal.}

  proc getCurrentAssetList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentAssetList)

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset]) =
    self.currentAssetList.setNewData(assetList)
    self.currentAssetListChanged()

  QtProperty[QVariant] assets:
    read = getCurrentAssetList
    write = setCurrentAssetList
    notify = currentAssetListChanged

  proc currentTransactionsChanged*(self: WalletView) {.signal.}

  proc getCurrentTransactions*(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentTransactions)

  proc setCurrentTransactions*(self: WalletView, transactionList: seq[Transaction]) =
    self.currentTransactions.setNewData(transactionList)
    self.currentTransactionsChanged()

  QtProperty[QVariant] transactions:
    read = getCurrentTransactions
    write = setCurrentTransactions
    notify = currentTransactionsChanged

  proc totalFiatBalanceChanged*(self: WalletView) {.signal.}

  proc getTotalFiatBalance(self: WalletView): string {.slot.} =
    self.status.wallet.getTotalFiatBalance()

  proc setTotalFiatBalance*(self: WalletView, newBalance: string) =
    self.totalFiatBalance = newBalance
    self.totalFiatBalanceChanged()

  QtProperty[string] totalFiatBalance:
    read = getTotalFiatBalance
    write = setTotalFiatBalance
    notify = totalFiatBalanceChanged

  proc accountListChanged*(self: WalletView) {.signal.}

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accounts.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accounts.rowCount == 1):
      self.setCurrentAssetList(account.assetList)
      self.setCurrentCollectiblesList(account.collectibles)
      self.setCurrentAccountByIndex(0)
    self.accountListChanged()

  proc generateNewAccount*(self: WalletView, password: string, accountName: string, color: string) {.slot.} =
    self.status.wallet.generateNewAccount(password, accountName, color)

  proc addAccountsFromSeed*(self: WalletView, seed: string, password: string, accountName: string, color: string) {.slot.} =
    self.status.wallet.addAccountsFromSeed(seed, password, accountName, color)

  proc addAccountsFromPrivateKey*(self: WalletView, privateKey: string, password: string, accountName: string, color: string) {.slot.} =
    self.status.wallet.addAccountsFromPrivateKey(privateKey, password, accountName, color)

  proc addWatchOnlyAccount*(self: WalletView, address: string, accountName: string, color: string) {.slot.} =
    self.status.wallet.addWatchOnlyAccount(address, accountName, color)

  proc changeAccountSettings*(self: WalletView, address: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.changeAccountSettings(address, accountName, color)
    if (result == ""):
      self.currentAccountChanged()
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc deleteAccount*(self: WalletView, address: string): string {.slot.} =
    result = self.status.wallet.deleteAccount(address)
    if (result == ""):
      let index = self.accounts.getAccountindexByAddress(address)
      if (index == -1):
        return fmt"Unable to find the account with the address {address}"
      self.accounts.deleteAccountAtIndex(index)
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc getAccountList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.accounts)

  QtProperty[QVariant] accounts:
    read = getAccountList
    notify = accountListChanged

  proc onSendTransaction*(self: WalletView, from_value: string, to: string, value: string, password: string): string {.slot.} =
    result = self.status.wallet.sendTransaction(from_value, to, value, password)

  proc getDefaultAccount*(self: WalletView): string {.slot.} =
    self.currentAccount.address

  proc defaultCurrency*(self: WalletView): string {.slot.} =
    self.status.wallet.getDefaultCurrency()

  proc defaultCurrencyChanged*(self: WalletView) {.signal.}

  proc setDefaultCurrency*(self: WalletView, currency: string) {.slot.} =
    self.status.wallet.setDefaultCurrency(currency)
    self.defaultCurrencyChanged()

  QtProperty[string] defaultCurrency:
    read = defaultCurrency
    write = setDefaultCurrency
    notify = defaultCurrencyChanged

  proc hasAsset*(self: WalletView, account: string, symbol: string): bool {.slot.} =
    self.status.wallet.hasAsset(account, symbol)

  proc toggleAsset*(self: WalletView, symbol: string, checked: bool, address: string, name: string, decimals: int, color: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol, checked, address, name, decimals, color)

  proc updateView*(self: WalletView) =
    self.totalFiatBalanceChanged()
    self.currentAccountChanged()
    self.accountListChanged()
    self.accounts.forceUpdate()
    self.setCurrentAssetList(self.currentAccount.account.assetList)
    self.setCurrentCollectiblesList(self.currentAccount.account.collectibles)

  proc addCustomToken*(self: WalletView, address: string, name: string, symbol: string, decimals: string) {.slot.} =
    self.status.wallet.toggleAsset(symbol, true, address, name, parseInt(decimals), "")

  proc loadTransactionsForAccount*(self: WalletView, address: string) {.slot.} =
    self.setCurrentTransactions(self.status.wallet.getTransfersByAddress(address))
