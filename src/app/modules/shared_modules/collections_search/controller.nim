import NimQml, std/json, sequtils, sugar, strutils
import logging

import app/modules/shared_models/collections_data_entry
import app/modules/shared_models/collections_data_model
import events_handler

import app/core/eventemitter

import backend/collectibles as backend_collectibles
import app_service/service/network/service as network_service

const FETCH_BATCH_COUNT_DEFAULT = 50

QtObject:
  type
    Controller* = ref object of QObject
      networkService: network_service.Service

      model: Model
      fetchFromStart: bool

      eventsHandler: EventsHandler

      requestId: int32

      chainId: int
      text: string

      isFetching: bool
      isError: bool

      previousCursor: string
      nextCursor: string
      provider: string

      dataType: backend_collectibles.CollectionDataType

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc mustFetchFromStart(self: Controller): bool =
    return self.previousCursor == ""

  proc hasMore(self: Controller): bool =
    return self.mustFetchFromStart() or self.nextCursor != ""

  proc getModel*(self: Controller): Model =
    return self.model

  proc getModelAsVariant*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.model)

  QtProperty[QVariant] model:
    read = getModelAsVariant

  proc isFetchingChanged(self: Controller) {.signal.}
  proc getIsFetching*(self: Controller): bool {.slot.} =
    self.isFetching
  QtProperty[bool] isFetching:
    read = getIsFetching
    notify = isFetchingChanged
  proc setIsFetching*(self: Controller, value: bool) =
    if value == self.isFetching:
      return
    self.isFetching = value
    self.isFetchingChanged()

  proc isErrorChanged(self: Controller) {.signal.}
  proc getIsError*(self: Controller): bool {.slot.} =
    self.isError
  QtProperty[bool] isError:
    read = getIsError
    notify = isErrorChanged
  proc setIsError*(self: Controller, value: bool) =
    if value == self.isError:
      return
    self.isError = value
    self.isErrorChanged()

  proc loadMoreItems(self: Controller) =
    if self.getIsFetching():
      return
    
    if not self.hasMore():
      return

    self.setIsFetching(true)
    self.setIsError(false)

    let params = backend_collectibles.SearchCollectionsParams(
      chainID: self.chainId,
      text: self.text,
      cursor: self.nextCursor,
      limit: FETCH_BATCH_COUNT_DEFAULT,
      providerID: self.provider
    )
    let response = backend_collectibles.searchCollectionsAsync(self.requestId, params, self.dataType)
    if response.error != nil:
      self.setIsFetching(false)
      self.setIsError(true)
      error "error searching collections: ", response.error

  proc resetModel(self: Controller) {.slot.} =
    self.model.setItems(@[], 0, true)

    self.previousCursor = ""
    self.nextCursor = ""
    self.provider = ""

    self.loadMoreItems() 

  proc textChanged(self: Controller) {.signal.}
  proc getText*(self: Controller): string {.slot.} =
    self.text

  QtProperty[string] text:
    read = getText
    notify = textChanged

  proc chainIdChanged(self: Controller) {.signal.}
  proc getChainId*(self: Controller): int {.slot.} =
    self.chainId

  QtProperty[int] chainId:
    read = getChainId
    notify = chainIdChanged
  
  proc search*(self: Controller, chainId: int, text: string) {.slot.} =
    if chainId == self.chainId and text == self.text:
      return

    self.chainId = chainId
    self.text = text
    self.resetModel()

  proc onModelLoadMoreItems(self: Controller) {.slot.} =
    self.loadMoreItems()

  proc processSearchCollectionsResponse(self: Controller, response: JsonNode) =
    let res = fromJson(response, backend_collectibles.SearchCollectionsResponse)

    let isError = res.errorCode != backend_collectibles.ErrorCodeSuccess

    if isError:
      error "error fetching collections entries: ", res.errorCode
      self.setIsError(true)
      self.setIsFetching(false)
      return

    if self.nextCursor != res.previousCursor:
      error "nextCursor mismatch"
      self.setIsError(true)
      self.setIsFetching(false)
      return

    self.previousCursor = res.previousCursor
    self.nextCursor = res.nextCursor
    self.provider = res.provider

    let items = res.collections.map(data => (block:
      newCollectionsDataFullEntry(data)
    ))
    self.model.setItems(items, self.model.getCount(), self.hasMore())
    self.setIsFetching(false)

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onSearchCollectionsDone(proc (jsonObj: JsonNode) =
      self.processSearchCollectionsResponse(jsonObj)
    )

  proc newController*(
    requestId: int32,
    networkService: network_service.Service,
    events: EventEmitter,
    dataType: backend_collectibles.CollectionDataType = backend_collectibles.CollectionDataType.Details,
    ): Controller =
    new(result, delete)

    result.requestId = requestId
    result.dataType = dataType

    result.networkService = networkService

    result.model = newModel()

    result.isFetching = false
    result.isError = false

    result.chainId = 0
    result.text = ""

    result.previousCursor = ""
    result.nextCursor = ""
    result.provider = ""
  
    result.eventsHandler = newEventsHandler(result.requestId, events)

    result.setup()

    result.setupEventHandlers()

    signalConnect(result.model, "loadMoreItems()", result, "onModelLoadMoreItems()")
