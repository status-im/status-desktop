import NimQml, strformat, strutils, chronicles

import view
import views/[asset_list, account_list, account_item]
import ../../status/libstatus/wallet as status_wallet
import ../../status/libstatus/settings as status_settings
import ../../status/libstatus/types as status_types
import ../../status/signals/types
import ../../status/[status, wallet]
import ../../status/wallet/account as WalletTypes
import ../../eventemitter

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
  self.status.wallet.initAccounts()
  var accounts = self.status.wallet.accounts
  for account in accounts:
    self.view.addAccountToList(account)

  self.view.initBalances()
  self.view.setDappBrowserAddress()

  self.status.events.on("accountsUpdated") do(e: Args):
    self.view.updateView()

  self.status.events.on("newAccountAdded") do(e: Args):
    var account = WalletTypes.AccountArgs(e)
    self.view.accounts.addAccountToList(account.account)
    self.view.updateView()

  self.status.events.on("assetChanged") do(e: Args):
    self.view.updateView()

  self.view.setEtherscanLink(status_settings.getCurrentNetworkDetails().etherscanLink)
  self.view.setSigningPhrase(status_settings.getSetting[string](Setting.SigningPhrase))

  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    var data = WalletSignal(e)
    case data.eventType:
      of "newblock":
        for acc in data.accounts:
          self.status.wallet.updateAccount(acc)
          self.status.wallet.checkPendingTransactions(acc, data.blockNumber)
          self.view.updateView()

          # TODO: show notification
      of "recent-history-fetching":
        self.view.setHistoryFetchState(data.accounts, true)
      of "recent-history-ready":
        self.view.setHistoryFetchState(data.accounts, false)

    # TODO: handle these data.eventType: history, reorg
    # see status-react/src/status_im/ethereum/subscriptions.cljs

  self.status.events.on(PendingTransactionType.WalletTransfer.confirmed) do(e: Args):
    let tx = TransactionMinedArgs(e)
    self.view.transactionCompleted(tx.success, tx.transactionHash, tx.revertReason)

proc checkPendingTransactions*(self: WalletController) =
  self.status.wallet.checkPendingTransactions() # TODO: consider doing this in a threadpool task

proc start*(self: WalletController) =
  status_wallet.startWallet(false)
