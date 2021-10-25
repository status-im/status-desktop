import NimQml, tables, stint, json, strformat, sequtils

import ./item
import ./model
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      fetchingHistoryState: Table[string, bool]

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc setItems*(self: View, items: seq[Item]) =
    self.model.setItems(items)

  proc historyWasFetched*(self: View) {.signal.}

  proc loadingTrxHistoryChanged*(self: View, isLoading: bool, address: string) {.signal.}

  proc setHistoryFetchState*(self: View, address: string, isFetching: bool) =
    self.fetchingHistoryState[address] = isFetching
    self.loadingTrxHistoryChanged(isFetching, address)

  proc setHistoryFetchState*(self: View, accounts: seq[string], isFetching: bool) =
    for acc in accounts:
      self.fetchingHistoryState[acc] = isFetching
      self.loadingTrxHistoryChanged(isFetching, acc)

  proc isFetchingHistory*(self: View, address: string): bool {.slot.} =
    if self.fetchingHistoryState.hasKey(address):
      return self.fetchingHistoryState[address]
    return true

  proc isHistoryFetched*(self: View, address: string): bool {.slot.} =
    return self.model.getCount() > 0

  proc loadTransactionsForAccount*(self: View, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) {.slot.} =
    self.setHistoryFetchState(address, true)
    self.delegate.loadTransactions(address, toBlock, limit, loadMore)

  proc checkRecentHistory*(self: View) {.slot.} =
    self.delegate.checkRecentHistory()

  proc setTrxHistoryResult*(self: View, transactions: seq[TransactionDto], address: string, wasFetchMore: bool) =
    self.model.addNewTransactions(transactions, wasFetchMore)
    
    self.setHistoryFetchState(address, false)

   
