import atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint
import NimQml, json, sequtils, chronicles, strutils, strformat, json

import
  ../../../status/[status, settings, wallet, tokens],
  ../../../status/tasks/[qt, task_runner_impl]

import account_list, account_item, transaction_list, accounts, asset_list, token_list, transactions

logScope:
  topics = "history-view"

QtObject:
  type HistoryView* = ref object of QObject
      status: Status
      accountsView: AccountsView
      transactionsView*: TransactionsView
      fetchingHistoryState: Table[string, bool]

  proc setup(self: HistoryView) = self.QObject.setup
  proc delete(self: HistoryView) = self.QObject.delete

  proc newHistoryView*(status: Status, accountsView: AccountsView, transactionsView: TransactionsView): HistoryView =
    new(result, delete)
    result.status = status
    result.fetchingHistoryState = initTable[string, bool]()
    result.accountsView = accountsView
    result.transactionsView = transactionsView
    result.setup

  proc historyWasFetched*(self: HistoryView) {.signal.}

  proc setHistoryFetchState*(self: HistoryView, accounts: seq[string], isFetching: bool) =
    for acc in accounts:
      self.fetchingHistoryState[acc] = isFetching
    if not isFetching: self.historyWasFetched()

  proc isFetchingHistory*(self: HistoryView, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: HistoryView, address: string): bool {.slot.} =
    return self.transactionsView.currentTransactions.rowCount() > 0

  proc loadingTrxHistoryChanged*(self: HistoryView, isLoading: bool) {.signal.}

  proc loadTransactionsForAccount*(self: HistoryView, address: string) {.slot.} =
    self.loadingTrxHistoryChanged(true)
    self.transactionsView.loadTransactions("setTrxHistoryResult", address)

  proc getLatestTransactionHistory*(self: HistoryView, accounts: seq[string]) =
    for acc in accounts:
      self.loadTransactionsForAccount(acc)

  proc setTrxHistoryResult(self: HistoryView, historyJSON: string) {.slot.} =
    let historyData = parseJson(historyJSON)
    let transactions = historyData["history"].to(seq[Transaction]);
    let address = historyData["address"].getStr
    let index = self.accountsView.accounts.getAccountindexByAddress(address)
    if index == -1: return
    self.accountsView.accounts.getAccount(index).transactions = transactions
    if address == self.accountsView.currentAccount.address:
      self.transactionsView.setCurrentTransactions(
            self.accountsView.accounts.getAccount(index).transactions)
    self.loadingTrxHistoryChanged(false)
