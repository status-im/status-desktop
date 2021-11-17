import algorithm, atomics, strutils, sequtils, json, tables, chronicles, web3/[ethtypes, conversions], stint, sugar
from sugar import `=>`, `->`
import NimQml, json, sequtils, chronicles, strutils

import
  status/[status, wallet, utils],
  status/wallet as status_wallet,
  status/types/[transaction]
import ../../../core/[main]
import ../../../core/tasks/[qt, threadpool]
import account_list, account_item, transaction_list, accounts, transactions

logScope:
  topics = "history-view"

type
  LoadTransactionsTaskArg = ref object of QObjectTaskArg
    address: string
    toBlock: Uint256
    limit: int
    loadMore: bool

const loadTransactionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadTransactionsTaskArg](argEncoded)
    output = %*{
      "address": arg.address,
      "history": status_wallet.getTransfersByAddress(arg.address, arg.toBlock, arg.limit, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)

proc loadTransactions*[T](self: T, slot: string, address: string, toBlock: Uint256, limit: int, loadMore: bool) =
  let arg = LoadTransactionsTaskArg(
    tptr: cast[ByteAddress](loadTransactionsTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    address: address,
    toBlock: toBlock,
    limit: limit,
    loadMore: loadMore
  )
  self.statusFoundation.threadpool.start(arg)

QtObject:
  type HistoryView* = ref object of QObject
      status: Status
      statusFoundation: StatusFoundation
      accountsView: AccountsView
      transactionsView*: TransactionsView
      fetchingHistoryState: Table[string, bool]

  proc setup(self: HistoryView) = self.QObject.setup
  proc delete(self: HistoryView) = self.QObject.delete

  proc newHistoryView*(status: Status, statusFoundation: StatusFoundation, 
    accountsView: AccountsView, transactionsView: TransactionsView): HistoryView =
    new(result, delete)
    result.status = status
    result.statusFoundation = statusFoundation
    result.fetchingHistoryState = initTable[string, bool]()
    result.accountsView = accountsView
    result.transactionsView = transactionsView
    result.setup

  proc historyWasFetched*(self: HistoryView) {.signal.}

  proc loadingTrxHistoryChanged*(self: HistoryView, isLoading: bool, address: string) {.signal.}

  proc setHistoryFetchState*(self: HistoryView, accounts: seq[string], isFetching: bool) =
    for acc in accounts:
      self.fetchingHistoryState[acc] = isFetching
      self.loadingTrxHistoryChanged(isFetching, acc)

  proc isFetchingHistory*(self: HistoryView, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: HistoryView, address: string): bool {.slot.} =
    return self.transactionsView.currentTransactions.rowCount() > 0

  proc loadTransactionsForAccount*(self: HistoryView, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) {.slot.} =
    self.loadingTrxHistoryChanged(true, address)
    let toBlockParsed = stint.fromHex(Uint256, toBlock)
    self.loadTransactions("setTrxHistoryResult", address, toBlockParsed, limit, loadMore)

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
