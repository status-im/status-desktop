import NimQml, std/json, sequtils, sugar, strutils
import stint, logging

import app/modules/shared_models/collectibles_model
import app/modules/shared_models/collectibles_utils
import events_handler

import app/core/eventemitter

import backend/collectibles as backend_collectibles

const FETCH_BATCH_COUNT_DEFAULT = 50

QtObject:
  type
    Controller* = ref object of QObject
      model: Model

      eventsHandler: EventsHandler

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

  proc processFilterOwnedCollectiblesResponse(self: Controller, response: JsonNode) =
    defer: self.model.setIsFetching(false)

    let res = fromJson(response, backend_collectibles.FilterOwnedCollectiblesResponse)

    let isError = res.errorCode != ErrorCodeSuccess
    defer: self.model.setIsError(isError)

    if isError:
      error "error fetching collectibles entries: ", res.errorCode
      return
    
    try: 
      let items = res.collectibles.map(header => collectibleToItem(header))
      self.model.setItems(items, res.offset, res.hasMore)
    except Exception as e:
      error "Error converting activity entries: ", e.msg

  proc updateFilter*(self: Controller) {.slot.} =
    self.model.resetModel(@[])

    let response = backend_collectibles.filterOwnedCollectiblesAsync(self.chainIds, self.addresses, 0, FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      self.model.setIsFetching(false)
      self.model.setIsError(true)
      error "error fetching collectibles entries: ", response.error
      return
    self.model.setIsFetching(true)
    self.model.setIsError(false)

  proc loadMoreItems(self: Controller) {.slot.} =
    if self.model.getIsFetching():
      return

    let response = backend_collectibles.filterOwnedCollectiblesAsync(self.chainIds, self.addresses, self.model.getCount(), FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      self.model.setIsError(true)
      error "error fetching collectibles entries: ", response.error
      return
    self.model.setIsFetching(true)
    self.model.setIsError(false)

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onOwnedCollectiblesFilteringDone(proc (jsonObj: JsonNode) =
      self.processFilterOwnedCollectiblesResponse(jsonObj)
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateFinished(proc () =
      self.updateFilter()
    )

  proc newController*(events: EventEmitter): Controller =
    new(result, delete)

    result.model = newModel()
  
    result.eventsHandler = newEventsHandler(events)

    result.addresses = @[]
    result.chainIds = @[]

    result.setup()

    result.setupEventHandlers()

    signalConnect(result.model, "loadMoreItems()", result, "loadMoreItems()")

  proc globalFilterChanged*(self: Controller, addresses: seq[string], chainIds: seq[int]) = 
    if chainIds == self.chainIds and addresses == self.addresses:
      return
    self.chainIds = chainIds
    self.addresses = addresses
    self.updateFilter()