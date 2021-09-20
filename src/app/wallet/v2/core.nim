import NimQml, strformat, strutils, chronicles, sugar, sequtils

import view
import views/[account_list, account_item, networks]

import status/[status, wallet2, settings]
import status/wallet2/account as WalletTypes
import status/types/[transaction, setting]
import ../../../app_service/[main]
import status/signals
import eventemitter

logScope:
  topics = "app-wallet2"

type WalletController* = ref object
  status: Status
  appService: AppService
  view*: WalletView
  variant*: QVariant

proc newController*(status: Status, appService: AppService): WalletController =
  result = WalletController()
  result.status = status
  result.appService = appService
  result.view = newWalletView(status, appService)
  result.variant = newQVariant(result.view)

proc delete*(self: WalletController) =
  delete self.variant
  delete self.view

proc init*(self: WalletController) =
  self.status.wallet2.init()
  self.view.networksView.updateNetworks(self.status.wallet2.networks)
  self.view.setSigningPhrase(self.status.settings.getSetting[:string](Setting.SigningPhrase))
  self.view.setEtherscanLink(self.status.settings.getCurrentNetworkDetails().etherscanLink)

  var accounts = self.status.wallet2.getAccounts()
  for account in accounts:
    self.view.addAccountToList(account)

  self.status.events.on("accountsUpdated") do(e: Args):
    self.view.updateView()

  self.status.events.on("newAccountAdded") do(e: Args):
    var account = WalletTypes.AccountArgs(e)
    self.view.addAccountToList(account.account)
    self.view.updateView()

  self.status.events.on("cryptoServicesFetched") do(e: Args):
    var args = CryptoServicesArg(e)
    self.view.onCryptoServicesFetched(args.services)

  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    debug "TODO: handle wallet signal", signalType=data.eventType
  
  self.status.events.on("cryptoServicesFetched") do(e: Args):
    var args = CryptoServicesArg(e)
    self.view.onCryptoServicesFetched(args.services)

  self.status.events.on("walletTransactionsFetched") do(e: Args):
    var args = WalletTransactionsArg(e)
    self.view.onWalletTransactionsFetched(args.address, args.transactions)