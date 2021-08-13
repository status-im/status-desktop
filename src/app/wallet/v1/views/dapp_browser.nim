import sequtils, json, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, json

import ../../../../status/[status, settings, wallet, types]

import account_list, account_item, accounts

logScope:
  topics = "ens-view"

QtObject:
  type DappBrowserView* = ref object of QObject
      status: Status
      accountsView: AccountsView
      dappBrowserAccount*: AccountItemView

  proc setup(self: DappBrowserView) = self.QObject.setup
  proc delete(self: DappBrowserView) =
    self.dappBrowserAccount.delete
    self.QObject.delete

  proc newDappBrowserView*(status: Status, accountsView: AccountsView): DappBrowserView =
    new(result, delete)
    result.status = status
    result.accountsView = accountsView
    result.dappBrowserAccount = newAccountItemView()
    result.setup

  proc dappBrowserAccountChanged*(self: DappBrowserView) {.signal.}

  proc setDappBrowserAddress*(self: DappBrowserView) {.slot.} =
    if(self.accountsView.accounts.rowCount() == 0): return

    let dappAddress = self.status.settings.getSetting[:string](Setting.DappsAddress)
    var index = self.accountsView.accounts.getAccountIndexByAddress(dappAddress)
    if index == -1: index = 0
    let selectedAccount = self.accountsView.accounts.getAccount(index)
    if self.dappBrowserAccount.address == selectedAccount.address: return
    self.dappBrowserAccount.setAccountItem(selectedAccount)
    self.dappBrowserAccountChanged()

  proc getDappBrowserAccount*(self: DappBrowserView): QVariant {.slot.} =
    result = newQVariant(self.dappBrowserAccount)

  QtProperty[QVariant] dappBrowserAccount:
    read = getDappBrowserAccount
    notify = dappBrowserAccountChanged
