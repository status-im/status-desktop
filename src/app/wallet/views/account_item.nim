import NimQml, std/wrapnils, strformat
from ../../../status/wallet import WalletAccount
import ./asset_list

QtObject:
  type AccountItemView* = ref object of QObject
    account*: WalletAccount
    assetList*: AssetList

  proc setup(self: AccountItemView) =
    self.QObject.setup

  proc delete*(self: AccountItemView) =
    self.QObject.delete

  proc newAccountItemView*(): AccountItemView =
    new(result, delete)
    let accountItemView = AccountItemView()
    accountItemView.assetList = newAssetList()
    result = accountItemView
    result.setup

  proc setAccountItem*(self: AccountItemView, account: WalletAccount) =
    self.account = account
    self.assetList.setNewData(account.assetList)

  proc name*(self: AccountItemView): string {.slot.} = result = ?.self.account.name
  QtProperty[string] name:
    read = name

  proc address*(self: AccountItemView): string {.slot.} = result = ?.self.account.address
  QtProperty[string] address:
    read = address

  proc iconColor*(self: AccountItemView): string {.slot.} = result = ?.self.account.iconColor
  QtProperty[string] iconColor:
    read = iconColor

  proc balance*(self: AccountItemView): string {.slot.} = result = ?.self.account.balance
  QtProperty[string] balance:
    read = balance
  
  proc fiatBalance*(self: AccountItemView): string {.slot.} = result = fmt"{?.self.account.realFiatBalance:>.2f}"
  QtProperty[string] fiatBalance:
    read = fiatBalance

  proc path*(self: AccountItemView): string {.slot.} = result = ?.self.account.path
  QtProperty[string] path:
    read = path

  proc walletType*(self: AccountItemView): string {.slot.} = result = ?.self.account.walletType
  QtProperty[string] walletType:
    read = walletType

  proc assets*(self: AccountItemView): QVariant {.slot.} = result = newQVariant(?.self.assetList)
  QtProperty[QVariant] assets:
    read = assets
