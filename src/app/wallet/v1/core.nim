import NimQml, strformat, strutils, chronicles, sugar, sequtils

import view
import views/[asset_list, account_list, account_item]

import ../../../status/[status, wallet, settings]
import ../../../status/wallet/account as WalletTypes
import ../../../status/types/[transaction, setting]
import ../../../app_service/[main]
import ../../../app_service/signals/[base]
import ../../../app_service/signals/wallet as wallet_signal
import ../../../eventemitter

logScope:
  topics = "wallet-core"

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
  self.status.wallet.initAccounts()
  var accounts = self.status.wallet.accounts
  for account in accounts:
    self.view.addAccountToList(account)

  self.view.checkRecentHistory()
  self.view.setDappBrowserAddress()

  self.status.events.on("accountsUpdated") do(e: Args):
    self.view.updateView()

  self.status.events.on("newAccountAdded") do(e: Args):
    var account = WalletTypes.AccountArgs(e)
    self.view.addAccountToList(account.account)
    self.view.updateView()

  self.status.events.on("assetChanged") do(e: Args):
    self.view.updateView()

  self.view.setSigningPhrase(self.status.settings.getSetting[:string](Setting.SigningPhrase))
  self.view.setEtherscanLink(self.status.settings.getCurrentNetworkDetails().etherscanLink)

  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "newblock":
        for acc in data.accounts:
          self.status.wallet.updateAccount(acc)
          self.status.wallet.checkPendingTransactions(acc, data.blockNumber)
          self.view.updateView()

          # TODO: show notification

      of "new-transfers":
        self.view.initBalances(data.accounts)
      of "recent-history-fetching":
        self.view.setHistoryFetchState(data.accounts, true)
      of "recent-history-ready":
        self.view.initBalances(data.accounts)
        self.view.setHistoryFetchState(data.accounts, false)
      of "non-archival-node-detected":
        self.view.setHistoryFetchState(self.status.wallet.accounts.map(account => account.address), false)
        self.view.setNonArchivalNode()
        warn "Non-archival node detected, please check your Infura key or your connected node"
      else:
        error "Unhandled wallet signal", eventType=data.eventType

    # TODO: handle these data.eventType: history, reorg
    # see status-react/src/status_im/ethereum/subscriptions.cljs

  self.status.events.on(PendingTransactionType.WalletTransfer.confirmed) do(e: Args):
    let tx = TransactionMinedArgs(e)
    self.view.transactionCompleted(tx.success, tx.transactionHash, tx.revertReason)

proc checkPendingTransactions*(self: WalletController) =
  self.status.wallet.checkPendingTransactions() # TODO: consider doing this in a threadpool task
