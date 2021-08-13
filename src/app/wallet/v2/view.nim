import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables
import NimQml, chronicles, stint

import
  ../../../status/[status, wallet],
  views/[accounts, account_list]

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      status: Status
      accountsView: AccountsView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accountsView = newAccountsView(status)
    result.setup

  proc getAccounts(self: WalletView): QVariant {.slot.} = newQVariant(self.accountsView)
  QtProperty[QVariant] accountsView:
    read = getAccounts

  proc updateView*(self: WalletView) =
    # TODO:
    self.accountsView.triggerUpdateAccounts()


  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      let selectedAccount = self.accountsView.accounts.getAccount(index)
      # TODO: load account details/transactions/collectibles/etc

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.setCurrentAccountByIndex(0)
