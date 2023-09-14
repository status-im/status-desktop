import NimQml, std/json, sequtils, sugar, strutils
import stint, logging, Tables

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
      fetchFromStart: bool

      eventsHandler: EventsHandler

      addresses: seq[string]
      chainIds: seq[int]

      stateTable: Table[string, Table[int, bool]] # Table[address][chainID] -> isUpdating

      requestId: int32
      autofetch: bool

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc getModel*(self: Controller): Model =
    return self.model

  proc getModelAsVariant*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.model)

  QtProperty[QVariant] model:
    read = getModelAsVariant

  proc loadMoreItems(self: Controller) {.slot.} =
    if self.model.getIsFetching():
      return

    self.model.setIsFetching(true)
    self.model.setIsError(false)

    var offset = 0
    if not self.fetchFromStart:
      offset = self.model.getCollectiblesCount()
    self.fetchFromStart = false

    let response = backend_collectibles.filterOwnedCollectiblesAsync(self.requestId, self.chainIds, self.addresses, offset, FETCH_BATCH_COUNT_DEFAULT)
    if response.error != nil:
      self.model.setIsFetching(false)
      self.model.setIsError(true)
      self.fetchFromStart = true
      error "error fetching collectibles entries: ", response.error

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

    if self.autofetch and res.hasMore:
      self.loadMoreItems()

  proc resetModel*(self: Controller) {.slot.} =
    self.model.setItems(@[], 0, true)
    self.fetchFromStart = true
    if self.autofetch:
      self.loadMoreItems()

  proc resetUpdateState*(self: Controller) =
    # Initialize state table
    # We assume that ownership is initially not being updated. This will change if an
    # update starts or a partial update is received.
    # TODO: Get the update state at the time of filter switch from the backend?
    self.stateTable = initTable[string, Table[int, bool]]()
    for address in self.addresses:
      self.stateTable[address] = initTable[int, bool]()
      for chainID in self.chainIds:
        self.stateTable[address][chainID] = false
    self.model.setIsUpdating(false)

  proc setUpdateState*(self: Controller, address: string, chainID: int, isUpdating: bool) =
    if not self.stateTable.hasKey(address) or not self.stateTable[address].hasKey(chainID):
      return
    self.stateTable[address][chainID] = isUpdating

    # If any address+chainID is updating, then the whole model is updating
    for address, chainIDsPerAddress in self.stateTable.pairs:
      for chainID, isUpdating in chainIDsPerAddress:
        if isUpdating:
          self.model.setIsUpdating(true)
          return
    self.model.setIsUpdating(false)

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onOwnedCollectiblesFilteringDone(proc (jsonObj: JsonNode) =
      self.processFilterOwnedCollectiblesResponse(jsonObj)
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateStarted(proc (address: string, chainID: int) =
      self.setUpdateState(address, chainID, true)
    )

    self.eventsHandler.onCollectiblesOwnershipUpdatePartial(proc (address: string, chainID: int) =
      self.setUpdateState(address, chainID, true)
      self.resetModel()
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateFinished(proc (address: string, chainID: int) =
      self.setUpdateState(address, chainID, false)
      self.resetModel()
    )

  proc newController*(requestId: int32, autofetch: bool, events: EventEmitter): Controller =
    new(result, delete)

    result.requestId = requestId
    result.autofetch = autofetch

    result.model = newModel()
    result.fetchFromStart = true
  
    result.eventsHandler = newEventsHandler(result.requestId, events)

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

    self.resetUpdateState()
  
    self.eventsHandler.updateSubscribedAddresses(self.addresses)
    self.eventsHandler.updateSubscribedChainIDs(self.chainIds)

    self.resetModel()
