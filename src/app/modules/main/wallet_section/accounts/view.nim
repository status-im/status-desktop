import NimQml, json, sequtils, strutils, tables

import app_service/service/wallet_account/service as wallet_account_service
import app/modules/shared_models/currency_amount

import ./model
import ./item
import ./io_interface

QtObject:
  type View* = ref object of QObject
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

  proc updateItems*(self: View, items: seq[Item]) =
    self.accounts.updateItems(items)

  proc updateBalance*(
      self: View, address: string, balance: CurrencyAmount, assetsLoading: bool
  ) =
    self.accounts.updateBalance(address, balance, assetsLoading)

  proc onAccountRemoved*(self: View, address: string) =
    self.accounts.deleteAccount(address)

  proc updateAccountsPositions*(self: View, values: Table[string, int]) =
    self.accounts.updateAccountsPositions(values)

  proc updateAccountHiddenFromTotalBalance*(
      self: View, address: string, hideFromTotalBalance: bool
  ) =
    self.accounts.updateAccountHiddenFromTotalBalance(address, hideFromTotalBalance)

  proc deleteAccount*(self: View, address: string) {.slot.} =
    self.delegate.deleteAccount(address)

  proc updateAccount(
      self: View, address: string, accountName: string, colorId: string, emoji: string
  ) {.slot.} =
    self.delegate.updateAccount(address, accountName, colorId, emoji)

  proc getNameByAddress(self: View, address: string): string {.slot.} =
    return self.accounts.getNameByAddress(address)

  proc getEmojiByAddress(self: View, address: string): string {.slot.} =
    return self.accounts.getEmojiByAddress(address)

  proc getColorByAddress(self: View, address: string): string {.slot.} =
    return self.accounts.getColorByAddress(address)

  proc isOwnedAccount(self: View, address: string): bool {.slot.} =
    return self.accounts.isOwnedAccount(address)

  proc updateWatchAccountHiddenFromTotalBalance*(
      self: View, address: string, hideFromTotalBalance: bool
  ) {.slot.} =
    self.delegate.updateWatchAccountHiddenFromTotalBalance(
      address, hideFromTotalBalance
    )

  proc getWalletAccountAsJson*(self: View, address: string): string {.slot.} =
    return $self.delegate.getWalletAccountAsJson(address)
