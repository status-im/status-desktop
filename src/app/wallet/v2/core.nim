import NimQml, strformat, strutils, chronicles, sugar, sequtils

import view
import views/[account_list, account_item]
import ../../../status/types as status_types
import ../../../status/signals/types
import ../../../status/[status, wallet, settings]
import ../../../status/wallet/account as WalletTypes
import ../../../eventemitter

logScope:
  topics = "wallet-core"

type WalletController* = ref object
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
  var accounts = self.status.wallet.accounts
  for account in accounts:
    self.view.addAccountToList(account)

  self.status.events.on("accountsUpdated") do(e: Args):
    self.view.updateView()

  self.status.events.on("newAccountAdded") do(e: Args):
    var account = WalletTypes.AccountArgs(e)
    self.view.addAccountToList(account.account)
    self.view.updateView()

  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    debug "TODO: handle wallet signal", signalType=data.eventType
