import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings]
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet

import account_list, account_item

logScope:
  topics = "accounts-view"

QtObject:
  type AccountsView* = ref object of QObject
      status: Status
      accounts*: AccountList
      currentAccount*: AccountItemView
      focusedAccount*: AccountItemView
    #   dappBrowserAccount*: AccountItemView

  proc setup(self: AccountsView) =
    self.QObject.setup

  proc delete(self: AccountsView) =
    self.accounts.delete
    self.currentAccount.delete
    self.focusedAccount.delete
    # self.dappBrowserAccount.delete

  proc newAccountsView*(status: Status): AccountsView =
    new(result, delete)
    result.status = status
    result.accounts = newAccountList()
    result.currentAccount = newAccountItemView()
    result.focusedAccount = newAccountItemView()
    result.setup
    # result.dappBrowserAccount = newAccountItemView()

  proc generateNewAccount*(self: AccountsView, password: string, accountName: string, color: string): string {.slot.} =
    try:
      self.status.wallet.generateNewAccount(password, accountName, color)
    except StatusGoException as e:
      result = StatusGoError(error: e.msg).toJson

  proc addAccountsFromSeed*(self: AccountsView, seed: string, password: string, accountName: string, color: string): string {.slot.} =
    try:
      self.status.wallet.addAccountsFromSeed(seed.strip(), password, accountName, color)
    except StatusGoException as e:
      result = StatusGoError(error: e.msg).toJson

  proc addAccountsFromPrivateKey*(self: AccountsView, privateKey: string, password: string, accountName: string, color: string): string {.slot.} =
    try:
      self.status.wallet.addAccountsFromPrivateKey(privateKey, password, accountName, color)
    except StatusGoException as e:
      result = StatusGoError(error: e.msg).toJson

  proc addWatchOnlyAccount*(self: AccountsView, address: string, accountName: string, color: string): string {.slot.} =
    self.status.wallet.addWatchOnlyAccount(address, accountName, color)

  proc currentAccountChanged*(self: AccountsView) {.signal.}

  proc accountListChanged*(self: AccountsView) {.signal.}

  proc addAccountToList*(self: AccountsView, account: WalletAccount) =
    self.accounts.addAccountToList(account)
    self.accountListChanged()

  proc changeAccountSettings*(self: AccountsView, address: string, accountName: string, color: string): string {.slot.} =
    result = self.status.wallet.changeAccountSettings(address, accountName, color)
    if (result == ""):
      self.currentAccountChanged()
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc deleteAccount*(self: AccountsView, address: string): string {.slot.} =
    result = self.status.wallet.deleteAccount(address)
    if (result == ""):
      let index = self.accounts.getAccountindexByAddress(address)
      if (index == -1):
        return fmt"Unable to find the account with the address {address}"
      self.accounts.deleteAccountAtIndex(index)
      self.accountListChanged()
      self.accounts.forceUpdate()

  proc getCurrentAccount*(self: AccountsView): QVariant {.slot.} =
    result = newQVariant(self.currentAccount)

  proc focusedAccountChanged*(self: AccountsView) {.signal.}

  proc setFocusedAccountByAddress*(self: AccountsView, address: string) {.slot.} =
    if (self.accounts.rowCount() == 0): return

    var index = self.accounts.getAccountindexByAddress(address)
    if index == -1: index = 0
    let selectedAccount = self.accounts.getAccount(index)
    if self.focusedAccount.address == selectedAccount.address: return
    self.focusedAccount.setAccountItem(selectedAccount)
    self.focusedAccountChanged()

  proc getFocusedAccount*(self: AccountsView): QVariant {.slot.} =
    result = newQVariant(self.focusedAccount)

  QtProperty[QVariant] focusedAccount:
    read = getFocusedAccount
    write = setFocusedAccountByAddress
    notify = focusedAccountChanged

  #TODO: use an Option here
  proc setCurrentAccountByIndex*(self: AccountsView, index: int): bool =
    if(self.accounts.rowCount() == 0): return false

    let selectedAccount = self.accounts.getAccount(index)
    if self.currentAccount.address == selectedAccount.address: return false
    self.currentAccount.setAccountItem(selectedAccount)
    self.currentAccountChanged()
    return true

  QtProperty[QVariant] currentAccount:
    read = getCurrentAccount
    write = setCurrentAccountByIndex
    notify = currentAccountChanged

  proc getAccountList(self: AccountsView): QVariant {.slot.} =
    return newQVariant(self.accounts)

  QtProperty[QVariant] accounts:
    read = getAccountList
    notify = accountListChanged

  proc getDefaultAccount*(self: AccountsView): string {.slot.} =
    self.currentAccount.address

  proc setAccountItems*(self: AccountsView) =
    for account in self.status.wallet.accounts:
      if account.address == self.currentAccount.address:
        self.currentAccount.setAccountItem(account)
      else:
        self.accounts.updateAssetsInList(account.address, account.assetList)
    self.accountListChanged()
    self.currentAccountChanged()

  proc triggerUpdateAccounts*(self: AccountsView) =
    self.currentAccountChanged()
    self.accountListChanged()
    self.accounts.forceUpdate()
