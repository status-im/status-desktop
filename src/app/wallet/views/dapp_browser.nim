import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint

import NimQml, json, sequtils, chronicles, strutils, strformat, json
import ../../../status/[status, settings, wallet, tokens]
import ../../../status/wallet/collectibles as status_collectibles
import ../../../status/signals/types as signal_types
import ../../../status/types

import # status-desktop libs
  ../../../status/wallet as status_wallet,
  ../../../status/utils as status_utils,
  ../../../status/tokens as status_tokens,
  ../../../status/ens as status_ens,
  ../../../status/tasks/[qt, task_runner_impl]

import account_list, account_item, transaction_list, accounts, asset_list, token_list

logScope:
  topics = "ens-view"

QtObject:
  type DappBrowserView* = ref object of QObject
      status: Status
      accountsView: AccountsView
      dappBrowserAccount*: AccountItemView

  proc setup(self: DappBrowserView) =
    self.QObject.setup

  proc delete(self: DappBrowserView) =
    self.dappBrowserAccount.delete

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
