import # std libs
  atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables

import # vendor libs
  NimQml, chronicles, stint

import # status-desktop libs
  # ../../status/[status, wallet, settings, tokens],
  ../../status/[status, wallet, settings],
  ../../status/wallet/collectibles as status_collectibles,
  ../../status/wallet as status_wallet,
  ../../status/types,
  ../../status/utils as status_utils,
  ../../status/tokens as status_tokens,
  ../../status/ens as status_ens,
  views/[asset_list, accounts, account_list, account_item, token_list, transaction_list, collectibles_list, collectibles, transactions, gas, tokens, ens, dapp_browser, history, balance, utils],
  ../../status/tasks/[qt, task_runner_impl], ../../status/signals/types as signal_types

QtObject:
  type
    WalletView* = ref object of QAbstractListModel
      status: Status
      accountsView: AccountsView
      collectiblesView: CollectiblesView
      transactionsView*: TransactionsView
      tokensView*: TokensView
      dappBrowserView*: DappBrowserView
      gasView*: GasView
      ensView*: EnsView
      historyView*: HistoryView
      balanceView*: BalanceView
      utilsView*: UtilsView

  proc delete(self: WalletView) =
    self.accountsView.delete
    self.gasView.delete
    self.ensView.delete
    self.utilsView.delete
    self.QAbstractListModel.delete

  proc setup(self: WalletView) =
    self.QAbstractListModel.setup

  proc newWalletView*(status: Status): WalletView =
    new(result, delete)
    result.status = status

    result.accountsView = newAccountsView(status)
    result.collectiblesView = newCollectiblesView(status, result.accountsView)
    result.transactionsView = newTransactionsView(status, result.accountsView)
    result.tokensView = newTokensView(status, result.accountsView)
    result.gasView = newGasView(status)
    result.ensView = newEnsView(status)
    result.dappBrowserView = newDappBrowserView(status, result.accountsView)
    result.historyView = newHistoryView(status, result.accountsView, result.transactionsView)
    result.balanceView = newBalanceView(status, result.accountsView, result.transactionsView, result.historyView)
    result.utilsView = newUtilsView(status)

    result.setup

  proc getAccounts(self: WalletView): QVariant {.slot.} =
    newQVariant(self.accountsView)

  QtProperty[QVariant] accountsView:
    read = getAccounts

  proc getCollectibles(self: WalletView): QVariant {.slot.} =
    newQVariant(self.collectiblesView)

  QtProperty[QVariant] collectiblesView:
    read = getCollectibles

  proc getTransactions(self: WalletView): QVariant {.slot.} =
    newQVariant(self.transactionsView)

  QtProperty[QVariant] transactionsView:
    read = getTransactions

  proc getGas(self: WalletView): QVariant {.slot.} =
    newQVariant(self.gasView)

  QtProperty[QVariant] gasView:
    read = getGas

  proc getTokens(self: WalletView): QVariant {.slot.} =
    newQVariant(self.tokensView)

  QtProperty[QVariant] tokensView:
    read = getTokens

  proc getEns(self: WalletView): QVariant {.slot.} =
    newQVariant(self.ensView)

  QtProperty[QVariant] ensView:
    read = getEns

  proc getHistory(self: WalletView): QVariant {.slot.} =
    newQVariant(self.historyView)

  QtProperty[QVariant] historyView:
    read = getHistory

  proc getBalance(self: WalletView): QVariant {.slot.} =
    newQVariant(self.balanceView)

  QtProperty[QVariant] balanceView:
    read = getBalance

  proc getUtils(self: WalletView): QVariant {.slot.} =
    newQVariant(self.utilsView)

  QtProperty[QVariant] utilsView:
    read = getUtils

  proc updateView*(self: WalletView) =
    self.balanceView.setTotalFiatBalance(self.status.wallet.getTotalFiatBalance())
    self.balanceView.totalFiatBalanceChanged()

    self.accountsView.currentAccount.assetList.setNewData(self.accountsView.currentAccount.account.assetList)
    self.accountsView.triggerUpdateAccounts()

    self.tokensView.setCurrentAssetList(self.accountsView.currentAccount.account.assetList)

  proc getAccountBalanceSuccess*(self: WalletView, jsonResponse: string) {.slot.} =
    self.balanceView.getAccountBalanceSuccess(jsonResponse)
    self.updateView()

  proc getDefaultAddress*(self: WalletView): string {.slot.} =
    result = $self.status.wallet.getWalletAccounts()[0].address

  proc setInitialRange*(self: WalletView) {.slot.} = 
    discard self.status.wallet.setInitialBlocksRange()

  proc setCurrentAccountByIndex*(self: WalletView, index: int) {.slot.} =
    if self.accountsView.setCurrentAccountByIndex(index):
      # TODO: get the account from above instead
      let selectedAccount = self.accountsView.accounts.getAccount(index)

      self.tokensView.setCurrentAssetList(selectedAccount.assetList)

      # Display currently known collectibles, and get latest from API/Contracts
      self.collectiblesView.setCurrentCollectiblesLists(selectedAccount.collectiblesLists)
      self.collectiblesView.loadCollectiblesForAccount(selectedAccount.address, selectedAccount.collectiblesLists)

      self.transactionsView.setCurrentTransactions(selectedAccount.transactions)

  proc addAccountToList*(self: WalletView, account: WalletAccount) =
    self.accountsView.addAccountToList(account)
    # If it's the first account we ever get, use its list as our first lists
    if (self.accountsView.accounts.rowCount == 1):
      self.tokensView.setCurrentAssetList(account.assetList)
      # discard self.accountsView.setCurrentAccountByIndex(0)
      discard self.accountsView.setCurrentAccountByIndex(0)
    # self.accountsView.accountListChanged()

  proc transactionCompleted*(self: WalletView, success: bool, txHash: string, revertReason: string = "") {.signal.}

  proc setDappBrowserAddress*(self: WalletView) {.slot.} =
    self.dappBrowserView.setDappBrowserAddress()

  proc loadTransactionsForAccount*(self: WalletView, address: string) {.slot.} =
    self.historyView.loadTransactionsForAccount(address)

  proc setHistoryFetchState*(self: WalletView, accounts: seq[string], isFetching: bool) =
    self.historyView.setHistoryFetchState(accounts, isFetching)

  proc initBalances*(self: WalletView, loadTransactions: bool = true) =
    self.balanceView.initBalances(loadTransactions)

  proc setSigningPhrase*(self: WalletView, signingPhrase: string) =
    self.utilsView.setSigningPhrase(signingPhrase)

  proc setEtherscanLink*(self: WalletView, link: string) =
    self.utilsView.setEtherscanLink(link)
