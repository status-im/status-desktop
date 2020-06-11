import NimQml
import ../../../status/libstatus/types
import std/wrapnils

QtObject:
  type AccountInfoView* = ref object of QObject
    account*: GeneratedAccount

  proc setup(self: AccountInfoView) =
    self.QObject.setup

  proc delete*(self: AccountInfoView) =
    self.QObject.delete

  proc newAccountInfoView*(): AccountInfoView =
    new(result, delete)
    result = AccountInfoView()
    result.setup

  proc accountChanged*(self: AccountInfoView) {.signal.}

  proc setAccount*(self: AccountInfoView, account: GeneratedAccount) =
    self.account = account
    self.accountChanged()

  proc username*(self: AccountInfoView): string {.slot.} = result = ?.self.account.name
  QtProperty[string] username:
    read = username
    notify = accountChanged

  proc identicon*(self: AccountInfoView): string {.slot.} = result = ?.self.account.photoPath
  QtProperty[string] identicon:
    read = identicon
    notify = accountChanged

  proc address*(self: AccountInfoView): string {.slot.} = result = ?.self.account.address
  QtProperty[string] address:
    read = address
    notify = accountChanged

  proc id*(self: AccountInfoView): string {.slot.} = result = ?.self.account.id
  QtProperty[string] id:
    read = id
    notify = accountChanged