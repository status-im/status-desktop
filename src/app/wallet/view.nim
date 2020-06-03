import NimQml
import Tables
import strformat
import views/asset_list
import views/account_list
import views/account_item
import ../../status/wallet
import ../../status/status

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      currentAccount: AccountItemView
      defaultAccount: string
      status: Status
      totalFiatBalance: float

  proc delete(self: WalletView) =
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = newAccountItemView()
    result.currentAssetList = newAssetList() # Temporarily set to an empty list
    result.setup

  proc currentAccountChanged*(self: WalletView) {.signal.}

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if(self.accounts.rowCount() == 0): return

    let selectedAccount = self.accounts.getAccount(index)
    if self.currentAccount.address == selectedAccount.address: return
    self.currentAccount.setAccountItem(selectedAccount)
    self.currentAccountChanged()

  proc getCurrentAccount*(self: WalletView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccountByIndex
    notify = currentAccountChanged

  proc currentAssetListChanged*(self: WalletView) {.signal.}

  proc getCurrentAssetList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.currentAssetList)

  proc setCurrentAssetList*(self: WalletView, assetList: AssetList) =
    self.currentAssetList = assetList
    self.currentAssetListChanged()

  QtProperty[QVariant] assets:
    read = getCurrentAssetList
    write = setCurrentAssetList
    notify = currentAssetListChanged

  proc totalFiatBalanceChanged*(self: WalletView) {.signal.}

  proc getTotalFiatBalance(self: WalletView): QVariant {.slot.} =
    return newQVariant(fmt"{self.totalFiatBalance:.2f} USD") # TODO use user's currency

  proc setTotalFiatBalance*(self: WalletView, newBalance: float) =
    self.totalFiatBalance = newBalance
    self.totalFiatBalanceChanged()

  QtProperty[QVariant] totalFiatBalance:
    read = getTotalFiatBalance
    write = setTotalFiatBalance
    notify = currentAssetListChanged
  
  proc accountListChanged*(self: WalletView) {.signal.}

  proc addAccountToList*(self: WalletView, account: Account) =
    self.accounts.addAccountToList(account)
    # If it's the first account we ever get, use its assetList as our currentAssetList
    if (self.accounts.rowCount == 1):
      self.setCurrentAssetList(account.assetList)
      self.setCurrentAccountByIndex(0)
    self.setTotalFiatBalance(account.realFiatBalance + self.totalFiatBalance)
    self.accountListChanged()

  proc getAccountList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.accounts)

  QtProperty[QVariant] accounts:
    read = getAccountList
    notify = accountListChanged

  proc onSendTransaction*(self: WalletView, from_value: string, to: string, value: string, password: string): string {.slot.} =
    result = self.status.wallet.sendTransaction(from_value, to, value, password)

  proc setDefaultAccount*(self: WalletView, account: string) =
    self.defaultAccount = account

  proc getDefaultAccount*(self: WalletView): string {.slot.} =
    return self.defaultAccount

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
