import NimQml, sequtils, strutils, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./model
import ./item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      accounts: Model
      accountsVariant: QVariant

  proc delete*(self: View) =
    self.accounts.delete
    self.accountsVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.accounts = newModel()
    result.accountsVariant = newQVariant(result.accounts)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc accountsChanged*(self: View) {.signal.}

  proc getAccounts(self: View): QVariant {.slot.} =
    return self.accountsVariant

  QtProperty[QVariant] accounts:
    read = getAccounts
    notify = accountsChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.accounts.setItems(items)

  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)

  proc updateAccount(self: View, address: string, accountName: string, color: string, emoji: string) {.slot.} =
    self.delegate.updateAccount(address, accountName, color, emoji)

  proc getNameByAddress(self: View, address: string): string {.slot.}=
    return self.accounts.getNameByAddress(address)

  proc getEmojiByAddress(self: View, address: string): string {.slot.}=
    return self.accounts.getEmojiByAddress(address)

  proc getColorByAddress(self: View, address: string): string {.slot.}=
    return self.accounts.getColorByAddress(address)
