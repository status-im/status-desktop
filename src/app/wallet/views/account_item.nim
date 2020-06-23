import NimQml, std/wrapnils
from ../../../status/wallet import WalletAccount

QtObject:
  type AccountItemView* = ref object of QObject
    account*: WalletAccount

  proc setup(self: AccountItemView) =
    self.QObject.setup

  proc delete*(self: AccountItemView) =
    self.QObject.delete

  proc newAccountItemView*(): AccountItemView =
    new(result, delete)
    result = AccountItemView()
    result.setup

  proc setAccountItem*(self: AccountItemView, account: WalletAccount) =
    self.account = account

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

  proc path*(self: AccountItemView): string {.slot.} = result = ?.self.account.path
  QtProperty[string] path:
    read = path

  proc walletType*(self: AccountItemView): string {.slot.} = result = ?.self.account.walletType
  QtProperty[string] walletType:
    read = walletType
