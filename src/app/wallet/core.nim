import NimQml, eventemitter, strformat, strutils, chronicles

import view
import views/[asset_list, account_list, account_item]
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/settings as status_settings
import ../../status/libstatus/types as status_types
import ../../signals/types

import ../../status/[status, wallet]
import ../../status/wallet/account as WalletTypes

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
  delete self.variant
  delete self.view

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

  self.view.setEtherscanLink(status_settings.getCurrentNetworkDetails().etherscanLink)

method onSignal(self: WalletController, data: Signal) =
  debug "New signal received"
  discard
