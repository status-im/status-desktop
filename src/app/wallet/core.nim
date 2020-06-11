import NimQml
import eventemitter
import strformat
import strutils
import chronicles

import view
import views/asset_list
import views/account_list
import views/account_item
import ../../status/libstatus/wallet as status_wallet
import ../../signals/types

import ../../status/wallet
import ../../status/wallet/account as WalletTypes
import ../../status/status

type WalletController* = ref object of SignalSubscriber
  status: Status
  view*: WalletView
  variant*: QVariant

proc newController*(status: Status): WalletController =
  result = WalletController()
  result.status = status
  result.view = newWalletView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: WalletController) =
  delete self.view
  delete self.variant

proc init*(self: WalletController) =
  self.status.wallet.initAccounts()
  var accounts = self.status.wallet.accounts
  for account in accounts:
    self.view.addAccountToList(account)
  self.view.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())

  self.status.events.on("accountsUpdated") do(e: Args):
    self.view.updateView()

  self.status.events.on("newAccountAdded") do(e: Args):
    var account = WalletTypes.AccountArgs(e)
    self.view.accounts.addAccountToList(account.account)

  self.status.events.on("assetChanged") do(e: Args):
    self.view.updateView()

method onSignal(self: WalletController, data: Signal) =
  debug "New signal received"
  discard
