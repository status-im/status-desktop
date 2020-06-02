import NimQml
import Tables
import views/asset_list
import views/account_list
import ../../status/wallet
import ../../status/status

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      accounts*: AccountList
      currentAssetList*: AssetList
      defaultAccount: string
      status: Status
      currentAccount: int8

  proc delete(self: WalletView) =
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = 0
    result.currentAssetList = newAssetList() # Temporarily set to an empty list
    result.setup

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
  
  proc addAccountToList*(self: WalletView, account: Account) =
    self.accounts.addAccountToList(account)
    # If it's the first account we ever get, use its assetList as our currentAssetList
    if (self.accounts.rowCount == 1):
      self.setCurrentAssetList(account.assetList)

  proc getAccountList(self: WalletView): QVariant {.slot.} =
    return newQVariant(self.accounts)

  QtProperty[QVariant] accounts:
    read = getAccountList

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
