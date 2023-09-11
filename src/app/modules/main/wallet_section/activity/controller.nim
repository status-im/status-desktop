import NimQml, logging, std/json, sequtils, sugar, options, strutils, locks
import tables, stint, sets

import model
import entry
import entry_details
import recipients_model
import events_handler
import status

import web3/conversions

import app/core/eventemitter
import app/core/signals/types

import backend/activity as backend_activity
import backend/backend as backend
import backend/transactions

import app_service/service/currency/service as currency_service
import app_service/service/transaction/service as transaction_service
import app_service/service/token/service as token_service

import app/modules/shared/wallet_utils
import app/modules/shared_models/currency_amount

import app_service/service/transaction/dto

proc toRef*[T](obj: T): ref T =
  new(result)
  result[] = obj

const FETCH_BATCH_COUNT_DEFAULT = 10
const FETCH_RECIPIENTS_BATCH_COUNT_DEFAULT = 2000

QtObject:
  type
    Controller* = ref object of QObject
      model: Model

      recipientsModel: RecipientsModel
      currentActivityFilter: backend_activity.ActivityFilter
      currencyService: currency_service.Service
      tokenService: token_service.Service
      activityDetails: ActivityDetails

      eventsHandler: EventsHandler
      status: Status

      # call updateAssetsIdentities after updating filterTokenCodes
      filterTokenCodes: HashSet[string]

      addresses: seq[string]
      # call updateAssetsIdentities after updating chainIds
      chainIds: seq[int]
      allChainsSelected: bool

      requestId: int32

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc getModel*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.model)

  QtProperty[QVariant] model:
    read = getModel

  proc getRecipientsModel*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.recipientsModel)

  QtProperty[QVariant] recipientsModel:
    read = getRecipientsModel

  proc buildMultiTransactionExtraData(self: Controller, metadata: backend_activity.ActivityEntry): ExtraData =
    if metadata.symbolIn.isSome():
      result.inAmount = self.currencyService.parseCurrencyValue(metadata.symbolIn.get(), metadata.amountIn)
    if metadata.symbolOut.isSome():
      result.outAmount = self.currencyService.parseCurrencyValue(metadata.symbolOut.get(), metadata.amountOut)

  proc buildTransactionExtraData(self: Controller, metadata: backend_activity.ActivityEntry): ExtraData =
    if metadata.symbolIn.isSome() or metadata.amountIn > 0:
      result.inAmount = self.currencyService.parseCurrencyValue(metadata.symbolIn.get(""), metadata.amountIn)
    if metadata.symbolOut.isSome() or metadata.amountOut > 0:
      result.outAmount = self.currencyService.parseCurrencyValue(metadata.symbolOut.get(""), metadata.amountOut)

  proc backendToPresentation(self: Controller, backendEntities: seq[backend_activity.ActivityEntry]): seq[entry.ActivityEntry] =
    let amountToCurrencyConvertor = proc(amount: UInt256, symbol: string): CurrencyAmount =
      return currencyAmountToItem(self.currencyService.parseCurrencyValue(symbol, amount),
                                self.currencyService.getCurrencyFormat(symbol))
    for backendEntry in backendEntities:
      var ae: entry.ActivityEntry
      case backendEntry.getPayloadType():
        of MultiTransaction:
          let extraData = self.buildMultiTransactionExtraData(backendEntry)
          ae = entry.newMultiTransactionActivityEntry(backendEntry, extraData, amountToCurrencyConvertor)
        of SimpleTransaction, PendingTransaction:
          let extraData = self.buildTransactionExtraData(backendEntry)
          ae = entry.newTransactionActivityEntry(backendEntry, self.addresses, extraData, amountToCurrencyConvertor)
      result.add(ae)

  proc fetchTxDetails*(self: Controller, entryIndex: int) {.slot.} =
    let amountToCurrencyConvertor = proc(amount: UInt256, symbol: string): CurrencyAmount =
      return currencyAmountToItem(self.currencyService.parseCurrencyValue(symbol, amount),
                                    self.currencyService.getCurrencyFormat(symbol))

    let entry = self.model.getEntry(entryIndex)
    if entry == nil:
      error "failed to find entry with index: ", entryIndex
      return

    try:
      self.activityDetails = newActivityDetails(entry.getMetadata(), amountToCurrencyConvertor)
    except Exception as e:
      let errDescription = e.msg
      error "error: ", errDescription
      return

  proc getActivityDetails(self: Controller): QVariant {.slot.} =
    return newQVariant(self.activityDetails)

  QtProperty[QVariant] activityDetails:
    read = getActivityDetails

  proc processResponse(self: Controller, response: JsonNode) =
    defer: self.status.setLoadingData(false)

    let res = fromJson(response, backend_activity.FilterResponse)

    defer: self.status.setErrorCode(res.errorCode.int)

    if res.errorCode != ErrorCodeSuccess:
      error "error fetching activity entries: ", res.errorCode
      return

    let entries = self.backendToPresentation(res.activities)

    self.model.setEntries(entries, res.offset, res.hasMore)

    if len(entries) > 0:
      self.eventsHandler.updateRelevantTimestamp(entries[len(entries) - 1].getTimestamp())

  proc updateFilter*(self: Controller) {.slot.} =
    self.status.setLoadingData(true)
    self.status.setIsFilterDirty(false)

    self.model.resetModel(@[])

    self.eventsHandler.updateSubscribedAddresses(self.addresses)
    self.eventsHandler.updateSubscribedChainIDs(self.chainIds)
    self.status.setNewDataAvailable(false)

    let chains = if not self.allChainsSelected: self.chainIds else: @[]
    let response = backend_activity.filterActivityAsync(self.requestId, self.addresses, seq[backend_activity.ChainId](chains), self.currentActivityFilter, 0, FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      error "error fetching activity entries: ", response.error
      self.status.setLoadingData(false)
      return

  proc loadMoreItems(self: Controller) {.slot.} =
    self.status.setLoadingData(true)
    let chains = if not self.allChainsSelected: self.chainIds else: @[]
    let response = backend_activity.filterActivityAsync(self.requestId, self.addresses, seq[backend_activity.ChainId](chains), self.currentActivityFilter, self.model.getCount(), FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      self.status.setLoadingData(false)
      error "error fetching activity entries: ", response.error
      return

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

  # Call this method on every data update (ideally only if updates are before the last timestamp retrieved)
  # This depends on self.addresses being set, call on every address change
  proc updateStartTimestamp*(self: Controller) {.slot.} =
    self.status.setLoadingStartTimestamp(true)

    let resJson = backend_activity.getOldestActivityTimestampAsync(self.requestId, self.addresses)
    if resJson.error != nil:
      self.status.setLoadingStartTimestamp(false)
      error "error requesting oldest activity timestamp: ", resJson.error
      return

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onFilteringDone(proc (jsonObj: JsonNode) =
      self.processResponse(jsonObj)
    )

    self.eventsHandler.onFilteringUpdateDone(proc (jn: JsonNode) =
      if jn.kind != JArray:
        error "expected an array"

      var entries = newSeq[backend_activity.Data](jn.len)
      for i in 0 ..< jn.len:
        entries[i] = fromJson(jn[i], backend_activity.Data)

      self.model.updateEntries(entries)
    )

    self.eventsHandler.onGetRecipientsDone(proc (jsonObj: JsonNode) =
      defer: self.status.setLoadingRecipients(false)
      let res = fromJson(jsonObj, backend_activity.GetRecipientsResponse)

      if res.errorCode != ErrorCodeSuccess:
        error "error fetching recipients: ", res.errorCode
        return

      self.recipientsModel.addAddresses(res.addresses, res.offset, res.hasMore)
    )

    self.eventsHandler.onGetOldestTimestampDone(proc (jsonObj: JsonNode) =
      defer: self.status.setLoadingStartTimestamp(false)
      let res = fromJson(jsonObj, backend_activity.GetOldestTimestampResponse)

      if res.errorCode != ErrorCodeSuccess:
        error "error fetching start timestamp: ", res.errorCode
        return

      self.status.setStartTimestamp(res.timestamp)
    )

    self.eventsHandler.onNewDataAvailable(proc () =
      self.status.setNewDataAvailable(true)
    )

  proc newController*(requestId: int32,
                      currencyService: currency_service.Service,
                      tokenService: token_service.Service,
                      events: EventEmitter): Controller =
    new(result, delete)

    result.requestId = requestId
    result.model = newModel()
    result.recipientsModel = newRecipientsModel()
    result.tokenService = tokenService
    result.currentActivityFilter = backend_activity.getIncludeAllActivityFilter()

    result.eventsHandler = newEventsHandler(result.requestId, events)
    result.status = newStatus()

    result.currencyService = currencyService

    result.filterTokenCodes = initHashSet[string]()

    result.addresses = @[]
    result.chainIds = @[]
    result.allChainsSelected = true

    result.setup()

    result.setupEventHandlers()

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

  # Depends on self.filterTokenCodes and self.chainIds, so should be called after updating them
  proc updateAssetsIdentities(self: Controller) =
    var assets = newSeq[backend_activity.Token]()
    for tokenCode in self.filterTokenCodes:
      for chainId in self.chainIds:
        let token = self.tokenService.findTokenBySymbol(chainId, tokenCode)
        if token != nil:
          let tokenType = if token.symbol == "ETH": backend_activity.TokenType.Native else: backend_activity.TokenType.Erc20
          assets.add(backend_activity.Token(
            tokenType: tokenType,
            chainId: backend_activity.ChainId(token.chainId),
            address: some(token.address)
          ))

    self.currentActivityFilter.assets = assets

  proc setFilterAssets*(self: Controller, assetsArrayJsonString: string, excludeAssets: bool) {.slot.} =
    self.filterTokenCodes.clear()
    if excludeAssets:
      return

    let assetsJson = parseJson(assetsArrayJsonString)
    if assetsJson.kind != JArray:
      error "invalid array of json strings"
      return

    for i in 0 ..< assetsJson.len:
      let tokenCode = assetsJson[i].getStr()
      self.filterTokenCodes.incl(tokenCode)

    self.updateAssetsIdentities()

  proc setFilterAddresses*(self: Controller, addresses: seq[string]) =
    self.addresses = addresses
    self.status.setIsFilterDirty(true)

    self.updateStartTimestamp()

  proc setFilterAddressesJson*(self: Controller, jsonArray: string) {.slot.}  =
    let addressesJson = parseJson(jsonArray)
    if addressesJson.kind != JArray:
      error "invalid array of json strings"
      return

    var addresses = newSeq[string]()
    for i in 0 ..< addressesJson.len:
      if addressesJson[i].kind != JString:
        error "not string entry in the json adday for index ", i
        return
      addresses.add(addressesJson[i].getStr())

    self.setFilterAddresses(addresses)

  proc setFilterToAddresses*(self: Controller, addresses: seq[string]) =
    self.currentActivityFilter.counterpartyAddresses = addresses

  proc setFilterChains*(self: Controller, chainIds: seq[int], allEnabled: bool) =
    self.chainIds = chainIds
    self.allChainsSelected = allEnabled
    self.status.setIsFilterDirty(true)

    self.updateAssetsIdentities()

  proc updateRecipientsModel*(self: Controller) {.slot.} =
    self.status.setLoadingRecipients(true)
    let res = backend_activity.getRecipientsAsync(self.requestId, 0, FETCH_RECIPIENTS_BATCH_COUNT_DEFAULT)
    if res.error != nil or res.result.kind != JBool:
      self.status.setLoadingRecipients(false)
      error "error fetching recipients: ", res.error, "; kind ", res.result.kind
      return

    # If the request was enqueued and already waiting for a response, we don't need to do anything
    if res.result.getBool():
      self.status.setLoadingRecipients(false)

  proc loadMoreRecipients(self: Controller) {.slot.} =
    self.status.setLoadingRecipients(true)
    let res = backend_activity.getRecipientsAsync(self.requestId, self.recipientsModel.getCount(), FETCH_RECIPIENTS_BATCH_COUNT_DEFAULT)
    if res.error != nil:
      self.status.setLoadingRecipients(false)
      error "error fetching more recipient entries: ", res.error
      return

    # If the request was enqueued and waiting for an answer, we don't need to do anything
    if res.result.getBool():
      self.status.setLoadingRecipients(false)

  proc updateFilterBase(self: Controller) {.slot.} =
    self.updateStartTimestamp()

  proc getStatus*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.status)

  QtProperty[QVariant] status:
    read = getStatus

  proc globalFilterChanged*(self: Controller, addresses: seq[string], chainIds: seq[int], allChainsEnabled: bool) =
    if (self.addresses == addresses and self.chainIds == chainIds):
      return
    self.setFilterAddresses(addresses)
    self.setFilterChains(chainIds, allChainsEnabled)

  proc noLimitTimestamp*(self: Controller): int {.slot.} =
    return backend_activity.noLimitTimestampForPeriod
