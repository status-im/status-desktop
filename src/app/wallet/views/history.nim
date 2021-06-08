import algorithm, atomics, strformat, strutils, sequtils, json, std/wrapnils, parseUtils, tables, chronicles, web3/[ethtypes, conversions], stint, sugar
from sugar import `=>`, `->`
import NimQml, json, sequtils, chronicles, strutils, strformat, json

import
  ../../../status/[status, settings, wallet, tokens, types, utils],
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

  proc loadingTrxHistoryChanged*(self: HistoryView, isLoading: bool, address: string) {.signal.}

  # proc loadTransactionsForAccount*(self: HistoryView, address: string) {.slot.} =
  #   self.loadingTrxHistoryChanged(true)
  #   self.transactionsView.loadTransactions("setTrxHistoryResult", address)

  proc loadTransactionsForAccount*(self: HistoryView, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) {.slot.} =
    self.loadingTrxHistoryChanged(true, address)
    let toBlockParsed = stint.fromHex(Uint256, toBlock)
    self.loadTransactions("setTrxHistoryResult", address, toBlockParsed, limit, loadMore)

  # proc getLatestTransactionHistory*(self: HistoryView, accounts: seq[string]) =
  #   for acc in accounts:
  #     self.loadTransactionsForAccount(acc)

  proc setTrxHistoryResult(self: HistoryView, historyJSON: string) {.slot.} =
    let
      historyData = parseJson(historyJSON)
      transactions = historyData["history"].to(seq[Transaction])
      address = historyData["address"].getStr
      wasFetchMore = historyData["loadMore"].getBool
      isCurrentAccount = address.toLowerAscii == self.accountsView.currentAccount.address.toLowerAscii
      index = self.accountsView.accounts.getAccountindexByAddress(address)
    if index == -1: return

    let account = self.accountsView.accounts.getAccount(index)
    # concatenate the new page of txs to existing account transactions,
    # sort them by block number and nonce, then deduplicate them based on their
    # transaction id.
    let existingAcctTxIds = account.transactions.data.map(tx => tx.id)
    let hasNewTxs = transactions.len > 0 and transactions.any(tx => not existingAcctTxIds.contains(tx.id))
    if hasNewTxs or not wasFetchMore:
      var allTxs: seq[Transaction] = account.transactions.data.concat(transactions)
      allTxs.sort(cmpTransactions, SortOrder.Descending)
      allTxs.deduplicate(tx => tx.id)
      account.transactions.data = allTxs
      account.transactions.hasMore = true
      if isCurrentAccount:
        self.transactionsView.currentTransactions.setHasMore(true)
        self.transactionsView.setCurrentTransactions(allTxs)
    else:
      account.transactions.hasMore = false
      if isCurrentAccount:
        self.transactionsView.currentTransactions.setHasMore(false)
        self.transactionsView.currentTransactionsChanged()
    self.loadingTrxHistoryChanged(false, address)
