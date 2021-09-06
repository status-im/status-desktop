import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables
import NimQml, chronicles, stint

import ../../../status/[status, wallet2]
import views/[accounts, account_list, collectibles]

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      status: Status
      accountsView: AccountsView
      collectiblesView: CollectiblesView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.collectiblesView.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status
    result.accountsView = newAccountsView(status)
    result.collectiblesView = newCollectiblesView(status)
    result.setup

  proc getAccounts(self: WalletView): QVariant {.slot.} = 
    newQVariant(self.accountsView)

  QtProperty[QVariant] accountsView:
    read = getAccounts

  proc getCollectibles(self: WalletView): QVariant {.slot.} = 
    return newQVariant(self.collectiblesView)

  QtProperty[QVariant] collectiblesView:
    read = getCollectibles

  proc updateView*(self: WalletView) =
    # TODO:
    self.accountsView.triggerUpdateAccounts()

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      let selectedAccount = self.accountsView.accounts.getAccount(index)
      self.collectiblesView.loadCollections(selectedAccount)
      # TODO: load account details/transactions/etc

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.setCurrentAccountByIndex(0)
