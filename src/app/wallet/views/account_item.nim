import NimQml
import std/wrapnils
import ./asset_list

type Account* = ref object
    name*, address*, iconColor*, balance*: string
    realFiatBalance*: float
    assetList*: AssetList

QtObject:
  type AccountItemView* = ref object of QObject
    account*: Account

  proc setup(self: AccountItemView) =
    self.QObject.setup

  proc delete*(self: AccountItemView) =
    self.QObject.delete

  proc newAccountItemView*(): AccountItemView =
    new(result, delete)
    result = AccountItemView()
    result.setup

  proc setAccountItem*(self: AccountItemView, account: Account) =
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
