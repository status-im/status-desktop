import NimQml, logging, std/json, sequtils, sugar, options
import tables

import model
import entry

import ../transactions/item
import ../transactions/module as transactions_module

import app/core/eventemitter
import app/core/signals/types

import backend/activity as backend_activity
import backend/backend as backend
import backend/transactions

import app_service/service/transaction/service as transaction_service

proc toRef*[T](obj: T): ref T =
  new(result)
  result[] = obj

const FETCH_BATCH_COUNT_DEFAULT = 10

QtObject:
  type
    Controller* = ref object of QObject
      model: Model
      transactionsModule: transactions_module.AccessInterface
      currentActivityFilter: backend_activity.ActivityFilter

      events: EventEmitter

      loadingData: bool
      errorCode: backend_activity.ErrorCode

      # TODO remove chains and addresses after using ground truth
      addresses: seq[string]
      chainIds: seq[int]

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc getModel*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.model)

  QtProperty[QVariant] model:
    read = getModel

  proc backendToPresentation(self: Controller, backendEntities: seq[backend_activity.ActivityEntry]): seq[entry.ActivityEntry] =
    var multiTransactionsIds: seq[int] = @[]
    var transactionIdentities: seq[backend.TransactionIdentity] = @[]
    var pendingTransactionIdentities: seq[backend.TransactionIdentity] = @[]

    # Extract metadata required to fetch details
    # TODO: temporary here to show the working API. Details for each entry will be done as required
    # on a detail request from UI after metadata is extended to include the required info
    for backendEntry in backendEntities:
      case backendEntry.payloadType:
        of MultiTransaction:
          multiTransactionsIds.add(backendEntry.id)
        of SimpleTransaction:
          transactionIdentities.add(backendEntry.transaction.get())
        of PendingTransaction:
          pendingTransactionIdentities.add(backendEntry.transaction.get())

    var multiTransactions = initTable[int, MultiTransactionDto]()
    if len(multiTransactionsIds) > 0:
      let mts = transaction_service.getMultiTransactions(multiTransactionsIds)
      for mt in mts:
        multiTransactions[mt.id] = mt

    var transactions = initTable[TransactionIdentity, ref Item]()
    if len(transactionIdentities) > 0:
      let response = backend.getTransfersForIdentities(transactionIdentities)
      let res = response.result
      if response.error != nil or res.kind != JArray or res.len == 0:
        raise newException(Defect, "failed fetching transaction details")

      let transactionsDtos = res.getElems().map(x => x.toTransactionDto())
      let trItems = self.transactionsModule.transactionsToItems(transactionsDtos, @[])
      for item in trItems:
        transactions[TransactionIdentity(chainId: item.getChainId(), hash: item.getId(), address: item.getAddress())] = toRef(item)

    var pendingTransactions = initTable[TransactionIdentity, ref Item]()
    if len(pendingTransactionIdentities) > 0:
      let response = backend.getPendingTransactionsForIdentities(pendingTransactionIdentities)
      let res = response.result
      if response.error != nil or res.kind != JArray or res.len == 0:
        raise newException(Defect, "failed fetching pending transactions details")

      let pendingTransactionsDtos = res.getElems().map(x => x.toPendingTransactionDto())
      let trItems = self.transactionsModule.transactionsToItems(pendingTransactionsDtos, @[])
      for item in trItems:
        pendingTransactions[TransactionIdentity(chainId: item.getChainId(), hash: item.getId(), address: item.getAddress())] = toRef(item)

    # Merge detailed transaction info in order
    result = newSeqOfCap[entry.ActivityEntry](multiTransactions.len + transactions.len + pendingTransactions.len)
    var mtIndex = 0
    var tIndex = 0
    var ptIndex = 0
    for backendEntry in backendEntities:
      case backendEntry.payloadType:
        of MultiTransaction:
          let id = multiTransactionsIds[mtIndex]
          if multiTransactions.hasKey(id):
            result.add(entry.newMultiTransactionActivityEntry(multiTransactions[id], backendEntry))
          else:
            error "failed to find multi transaction with id: ", id
          mtIndex += 1
        of SimpleTransaction:
          let identity = transactionIdentities[tIndex]
          if transactions.hasKey(identity):
            result.add(entry.newTransactionActivityEntry(transactions[identity], backendEntry))
          else:
            error "failed to find transaction with identity: ", identity
          tIndex += 1
        of PendingTransaction:
          let identity = pendingTransactionIdentities[ptIndex]
          if pendingTransactions.hasKey(identity):
            result.add(entry.newTransactionActivityEntry(pendingTransactions[identity], backendEntry))
          else:
            error "failed to find pending transaction with identity: ", identity
          ptIndex += 1

  proc loadingDataChanged*(self: Controller) {.signal.}

  proc setLoadingData(self: Controller, loadingData: bool) =
    self.loadingData = loadingData
    self.loadingDataChanged()

  proc errorCodeChanged*(self: Controller) {.signal.}

  proc setErrorCode(self: Controller, errorCode: int) =
    self.errorCode = backend_activity.ErrorCode(errorCode)
    self.errorCodeChanged()

  proc processResponse(self: Controller, response: JsonNode) =
    defer: self.setLoadingData(false)

    let res = fromJson(response, backend_activity.FilterResponse)

    defer: self.setErrorCode(res.errorCode.int)

    if res.errorCode != ErrorCodeSuccess:
      error "error fetching activity entries: ", res.errorCode
      return

    let entries = self.backendToPresentation(res.activities)
    self.model.setEntries(entries, res.offset, res.hasMore)

  proc updateFilter*(self: Controller) {.slot.} =
    self.setLoadingData(true)
    let response = backend_activity.filterActivityAsync(self.addresses, self.chainIds, self.currentActivityFilter, 0, FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      error "error fetching activity entries: ", response.error
      self.setLoadingData(false)
      return

  proc loadMoreItems(self: Controller) {.slot.} =
    let response = backend_activity.filterActivityAsync(self.addresses, self.chainIds, self.currentActivityFilter, self.model.getCount(), FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      error "error fetching activity entries: ", response.error
      return

    self.setLoadingData(true)

  proc setFilterTime*(self: Controller, startTimestamp: int, endTimestamp: int) {.slot.} =
    self.currentActivityFilter.period = backend_activity.newPeriod(startTimestamp, endTimestamp)

  proc setFilterType*(self: Controller, typesArrayJsonString: string) {.slot.} =
    let typesJson = parseJson(typesArrayJsonString)
    if typesJson.kind != JArray:
      error "invalid array of json ints"
      return

    var types = newSeq[backend_activity.ActivityType](typesJson.len)
    for i in 0 ..< typesJson.len:
      types[i] = backend_activity.ActivityType(typesJson[i].getInt())

    self.currentActivityFilter.types = types

  proc newController*(transactionsModule: transactions_module.AccessInterface, events: EventEmitter): Controller =
    new(result, delete)
    result.model = newModel()
    result.transactionsModule = transactionsModule
    result.currentActivityFilter = backend_activity.getIncludeAllActivityFilter()
    result.events = events
    result.setup()

    let controller = result

    proc handleEvent(e: Args) =
      var data = WalletSignal(e)
      case data.eventType:
        of backend_activity.eventActivityFilteringDone:
          let responseJson = parseJson(data.message)
          if responseJson.kind != JObject:
            error "unexpected json type", responseJson.kind
            return

          controller.processResponse(responseJson)
        else:
          discard

    result.events.on(SignalType.Wallet.event, handleEvent)

  proc setFilterStatus*(self: Controller, statusesArrayJsonString: string) {.slot.} =
    let statusesJson = parseJson(statusesArrayJsonString)
    if statusesJson.kind != JArray:
      error "invalid array of json ints"
      return

    var statuses = newSeq[backend_activity.ActivityStatus](statusesJson.len)
    for i in 0 ..< statusesJson.len:
      statuses[i] = backend_activity.ActivityStatus(statusesJson[i].getInt())

    self.currentActivityFilter.statuses = statuses

  proc setFilterToAddresses*(self: Controller, addressesArrayJsonString: string) {.slot.} =
    let addressesJson = parseJson(addressesArrayJsonString)
    if addressesJson.kind != JArray:
      error "invalid array of json strings"
      return

    var addresses = newSeq[string](addressesJson.len)
    for i in 0 ..< addressesJson.len:
      addresses[i] = addressesJson[i].getStr()

    self.currentActivityFilter.counterpartyAddresses = addresses

  proc setFilterAssets*(self: Controller, assetsArrayJsonString: string) {.slot.} =
    let assetsJson = parseJson(assetsArrayJsonString)
    if assetsJson.kind != JArray:
      error "invalid array of json strings"
      return

    var assets = newSeq[TokenCode](assetsJson.len)
    for i in 0 ..< assetsJson.len:
      assets[i] = TokenCode(assetsJson[i].getStr())

    self.currentActivityFilter.tokens.assets = option(assets)

  # TODO: remove me and use ground truth
  proc setFilterAddresses*(self: Controller, addressesArrayJsonString: string) {.slot.} =
    let addressesJson = parseJson(addressesArrayJsonString)
    if addressesJson.kind != JArray:
      error "invalid array of json strings"
      return

    var addresses = newSeq[string](addressesJson.len)
    for i in 0 ..< addressesJson.len:
      addresses[i] = addressesJson[i].getStr()

    self.addresses = addresses

  # TODO: remove me and use ground truth
  proc setFilterChains*(self: Controller, chainIdsArrayJsonString: string) {.slot.} =
    let chainIdsJson = parseJson(chainIdsArrayJsonString)
    if chainIdsJson.kind != JArray:
      error "invalid array of json ints"
      return

    var chainIds = newSeq[int](chainIdsJson.len)
    for i in 0 ..< chainIdsJson.len:
      chainIds[i] = chainIdsJson[i].getInt()

    self.chainIds = chainIds

  proc getLoadingData*(self: Controller): bool {.slot.} =
    return self.loadingData

  QtProperty[bool] loadingData:
    read = getLoadingData
    notify = loadingDataChanged

  proc getErrorCode*(self: Controller): int {.slot.} =
    return self.errorCode.int

  QtProperty[int] errorCode:
    read = getErrorCode
    notify = errorCodeChanged