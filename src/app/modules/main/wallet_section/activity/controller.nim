import NimQml, logging, std/json, sequtils, sugar, options

import model
import entry

import ../transactions/item
import ../transactions/module as transactions_module

import backend/activity as backend_activity
import backend/backend as backend
import backend/transactions

import app_service/service/transaction/service as transaction_service

proc toRef*[T](obj: T): ref T =
  new(result)
  result[] = obj

QtObject:
  type
    Controller* = ref object of QObject
      model: Model
      transactionsModule: transactions_module.AccessInterface
      currentActivityFilter: backend_activity.ActivityFilter

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc newController*(transactionsModule: transactions_module.AccessInterface): Controller =
    new(result, delete)
    result.model = newModel()
    result.transactionsModule = transactionsModule
    result.currentActivityFilter = backend_activity.getIncludeAllActivityFilter()
    result.setup()

  proc getModel*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.model)

  QtProperty[QVariant] model:
    read = getModel

  # TODO: move it to service, make it async and lazy load details for transactions
  proc backendToPresentation(self: Controller, backendEnties: seq[backend_activity.ActivityEntry]): seq[entry.ActivityEntry] =
    var multiTransactionsIds: seq[int] = @[]
    var transactionIdentities: seq[backend.TransactionIdentity] = @[]
    var pendingTransactionIdentities: seq[backend.TransactionIdentity] = @[]

    # Extract metadata required to fetch details
    # TODO: temporary here to show the working API. Will be done as required on a detail request from UI
    for backendEntry in backendEnties:
      case backendEntry.transactionType:
        of MultiTransaction:
          multiTransactionsIds.add(backendEntry.id)
        of SimpleTransaction:
          transactionIdentities.add(backendEntry.transaction.get())
        of PendingTransaction:
          pendingTransactionIdentities.add(backendEntry.transaction.get())

    var multiTransactions: seq[MultiTransactionDto] = @[]
    if len(multiTransactionsIds) > 0:
      multiTransactions = transaction_service.getMultiTransactions(multiTransactionsIds)

    var transactions: seq[Item] = @[]
    if len(transactionIdentities) > 0:
      let response = backend.getTransfersForIdentities(transactionIdentities)
      let res = response.result
      if response.error != nil or res.kind != JArray or res.len == 0:
        raise newException(Defect, "failed fetching transaction details")

      let transactionsDtos = res.getElems().map(x => x.toTransactionDto())
      transactions = self.transactionsModule.transactionsToItems(transactionsDtos, @[])

    var pendingTransactions: seq[Item] = @[]
    if len(pendingTransactionIdentities) > 0:
      let response = backend.getPendingTransactionsForIdentities(pendingTransactionIdentities)
      let res = response.result
      if response.error != nil or res.kind != JArray or res.len == 0:
        raise newException(Defect, "failed fetching pending transactions details")

      let pendingTransactionsDtos = res.getElems().map(x => x.toPendingTransactionDto())
      pendingTransactions = self.transactionsModule.transactionsToItems(pendingTransactionsDtos, @[])

    # Merge detailed transaction info in order
    result = newSeq[entry.ActivityEntry](multiTransactions.len + transactions.len + pendingTransactions.len)
    var mtIndex = 0
    var tIndex = 0
    var ptIndex = 0
    for i in low(backendEnties) .. high(backendEnties):
      let backendEntry = backendEnties[i]
      case backendEntry.transactionType:
        of MultiTransaction:
          result[i] = entry.newMultiTransactionActivityEntry(multiTransactions[mtIndex])
          mtIndex += 1
        of SimpleTransaction:
          let refInstance = new(Item)
          refInstance[] = transactions[tIndex]
          result[i] = entry.newTransactionActivityEntry(refInstance, false)
          tIndex += 1
        of PendingTransaction:
          let refInstance = new(Item)
          refInstance[] = pendingTransactions[ptIndex]
          result[i] = entry.newTransactionActivityEntry(refInstance, true)
          ptIndex += 1

  proc refreshData*(self: Controller) {.slot.} =
    # result type is RpcResponse
    let response = backend_activity.getActivityEntries(@["0x0000000000000000000000000000000000000001"], @[1], self.currentActivityFilter, 0, 10)
    # RPC returns null for result in case of empty array
    if response.error != nil or (response.result.kind != JArray and response.result.kind != JNull):
      error "error fetching activity entries: ", response.error
      return

    if response.result.kind == JNull:
      self.model.setEntries(@[])
      return

    var backendEnties = newSeq[backend_activity.ActivityEntry](response.result.len)
    for i in 0 ..< response.result.len:
      backendEnties[i] = fromJson(response.result[i], backend_activity.ActivityEntry)
    let entries = self.backendToPresentation(backendEnties)
    self.model.setEntries(entries)

  # TODO: add all parameters and separate in different methods
  proc updateFilter*(self: Controller, startTimestamp: int, endTimestamp: int) {.slot.} =
    # Update filter
    self.currentActivityFilter.period = backend_activity.newPeriod(startTimestamp, endTimestamp)

    self.refreshData()
