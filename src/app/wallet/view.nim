import NimQml
import Tables
import strformat
import strutils
import views/asset_list
import views/account_list
import views/account_item
import ../../status/wallet
import ../../status/status
import chronicles

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      currentAccount: AccountItemView
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
    result.currentAssetList = newAssetList()
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

  proc setCurrentAssetList*(self: WalletView, assetList: seq[Asset]) =
    self.currentAssetList.setNewData(assetList)
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

  proc generateNewAccount*(self: WalletView, password: string, accountName: string, color: string) {.slot.} =
    # TODO move all this to the model to add a real account
    # let assetList = newAssetList()
    var assetList: seq[Asset] = @[]
    let symbol = "ETH"
    let asset = Asset(name:"Ethereum", symbol: symbol, value: fmt"0", fiatValue: "$0.00", image: fmt"../../img/token-icons/{toLowerAscii(symbol)}.svg")
    # assetList.addAssetToList(asset)
    let defaultCurrency = "USD" # TODO get real default
    # TODO get a real address that we unlock with the password
    let account = Account(name: accountName, address: "0x0r329ru298u392r", iconColor: color, balance: fmt"0.00 {defaultCurrency}", assetList: assetList, realFiatBalance: 0.0)
    self.addAccountToList(account)

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
