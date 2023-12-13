import NimQml, std/json, sequtils, sugar, strutils
import stint, logging, Tables

import app/modules/shared_models/collectibles_entry
import app/modules/shared_models/collectibles_model
import app/modules/shared_models/collectibles_utils
import events_handler

import app/core/eventemitter

import backend/collectibles as backend_collectibles
import backend/activity as backend_activity
import app_service/service/network/service as network_service

const FETCH_BATCH_COUNT_DEFAULT = 50

QtObject:
  type
    Controller* = ref object of QObject
      networkService: network_service.Service

      model: Model
      fetchFromStart: bool

      eventsHandler: EventsHandler

      addresses: seq[string]
      chainIds: seq[int]
      filter: backend_collectibles.CollectibleFilter

      ownershipStatus: Table[string, Table[int, OwnershipStatus]] # Table[address][chainID] -> OwnershipStatus

      requestId: int32
      autofetch: bool

      dataType: backend_collectibles.CollectibleDataType
      fetchCriteria: backend_collectibles.FetchCriteria

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

  proc checkModelState(self: Controller) =
    var overallState = OwnershipStateIdle

    # If any address+chainID is error, then the whole model is error
    # Otherwise, if any address+chainID is updating, then the whole model is updating
    # Otherwise, the model is idle
    for address, statusPerChainID in self.ownershipStatus.pairs:
      for chainID, status in statusPerChainID:
        if status.state == OwnershipStateError:
          overallState = OwnershipStateError
          break
        elif status.state == OwnershipStateUpdating:
          overallState = OwnershipStateUpdating
          break

    case overallState:
      of OwnershipStateIdle, OwnershipStateDelayed:
        self.model.setIsUpdating(false)
        self.model.setIsError(false)
      of OwnershipStateUpdating:
        self.model.setIsUpdating(true)
        self.model.setIsError(false)
      of OwnershipStateError:
        self.model.setIsUpdating(false)
        self.model.setIsError(true)

  proc resetOwnershipStatus(self: Controller) =
    # Initialize state table
    self.ownershipStatus = initTable[string, Table[int, OwnershipStatus]]()
    for address in self.addresses:
      self.ownershipStatus[address] = initTable[int, OwnershipStatus]()
      for chainID in self.chainIds:
        self.ownershipStatus[address][chainID] = OwnershipStatus(
          state: OwnershipStateUpdating,
          timestamp: invalidTimestamp
        )
    self.model.setIsUpdating(true)

  proc setOwnershipStatus(self: Controller, statusPerAddressAndChainID: Table[string, Table[int, OwnershipStatus]]) =
    for address, statusPerChainID in statusPerAddressAndChainID.pairs:
      if not self.ownershipStatus.hasKey(address):
        continue
      for chainID, status in statusPerChainID:
        if not self.ownershipStatus[address].hasKey(chainID):
          continue
        self.ownershipStatus[address][chainID] = status

    self.checkModelState()

  proc setOwnershipState(self: Controller, address: string, chainID: int, state: OwnershipState) =
    if not self.ownershipStatus.hasKey(address) or not self.ownershipStatus[address].hasKey(chainID):
      return
    self.ownershipStatus[address][chainID].state = state

    self.checkModelState()

  proc loadMoreItems(self: Controller) {.slot.} =
    if self.model.getIsFetching():
      return

    self.model.setIsFetching(true)
    self.model.setIsError(false)

    var offset = 0
    if not self.fetchFromStart:
      offset = self.model.getCollectiblesCount()
    self.fetchFromStart = false

    let response = backend_collectibles.getOwnedCollectiblesAsync(self.requestId, self.chainIds, self.addresses, self.filter, offset, FETCH_BATCH_COUNT_DEFAULT, self.dataType, self.fetchCriteria)
    if response.error != nil:
      self.model.setIsFetching(false)
      self.model.setIsError(true)
      self.fetchFromStart = true
      error "error fetching collectibles entries: ", response.error

  proc getExtraData(self: Controller, chainID: int): ExtraData =
    let network = self.networkService.getNetwork(chainID)
    return getExtraData(network)

  proc processGetOwnedCollectiblesResponse(self: Controller, response: JsonNode) =
    defer: self.model.setIsFetching(false)

    let res = fromJson(response, backend_collectibles.GetOwnedCollectiblesResponse)

    let isError = res.errorCode != backend_collectibles.ErrorCodeSuccess

    if isError:
      error "error fetching collectibles entries: ", res.errorCode
      self.model.setIsError(true)
      return
    
    try: 
      let items = res.collectibles.map(header => (block:
        let extradata = self.getExtraData(header.id.contractID.chainID)
        newCollectibleDetailsFullEntry(header, extradata)
      ))
      self.model.setItems(items, res.offset, res.hasMore)
    except Exception as e:
      error "Error converting activity entries: ", e.msg

    self.setOwnershipStatus(res.ownershipStatus)

    if self.autofetch and res.hasMore:
      self.loadMoreItems()

  proc processCollectiblesDataUpdate(self: Controller, jsonObj: JsonNode) =
      if jsonObj.kind != JArray:
        error "processCollectiblesDataUpdate expected an array"

      var collectibles: seq[backend_collectibles.Collectible]
      for jsonCollectible in jsonObj.getElems():
        let collectible = fromJson(jsonCollectible, backend_collectibles.Collectible)
        collectibles.add(collectible)
      self.model.updateItems(collectibles)

  proc resetModel(self: Controller) {.slot.} =
    self.model.setItems(@[], 0, true)
    self.fetchFromStart = true
    if self.autofetch:
      self.loadMoreItems()

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onOwnedCollectiblesFilteringDone(proc (jsonObj: JsonNode) =
      self.processGetOwnedCollectiblesResponse(jsonObj)
    )

    self.eventsHandler.onCollectiblesDataUpdate(proc (jsonObj: JsonNode) =
      self.processCollectiblesDataUpdate(jsonObj)
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateStarted(proc (address: string, chainID: int) =
      self.setOwnershipState(address, chainID, OwnershipStateUpdating)
    )

    self.eventsHandler.onCollectiblesOwnershipUpdatePartial(proc (address: string, chainID: int) =
      self.setOwnershipState(address, chainID, OwnershipStateUpdating)
      self.resetModel()
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateFinished(proc (address: string, chainID: int) =
      self.setOwnershipState(address, chainID, OwnershipStateIdle)
      self.resetModel()
    )

    self.eventsHandler.onCollectiblesOwnershipUpdateFinishedWithError(proc (address: string, chainID: int) =
      self.setOwnershipState(address, chainID, OwnershipStateError)
    )

  proc newController*(
    requestId: int32,
    networkService: network_service.Service,
    events: EventEmitter,
    autofetch: bool = true,
    dataType: backend_collectibles.CollectibleDataType = backend_collectibles.CollectibleDataType.Header,
    fetchCriteria: backend_collectibles.FetchCriteria = backend_collectibles.FetchCriteria(
      fetchType: backend_collectibles.FetchType.NeverFetch,
    )): Controller =
    new(result, delete)

    result.requestId = requestId
    result.autofetch = autofetch
    result.dataType = dataType
    result.fetchCriteria = fetchCriteria

    result.networkService = networkService

    result.model = newModel()
    result.fetchFromStart = true
  
    result.eventsHandler = newEventsHandler(result.requestId, events)

    result.addresses = @[]
    result.chainIds = @[]
    result.filter = backend_collectibles.newCollectibleFilterAllEntries()

    result.setup()

    result.setupEventHandlers()

    signalConnect(result.model, "loadMoreItems()", result, "loadMoreItems()")

  proc setFilterAddressesAndChains*(self: Controller, addresses: seq[string], chainIds: seq[int]) = 
    if chainIds == self.chainIds and addresses == self.addresses:
      return

    self.chainIds = chainIds
    self.addresses = addresses

    self.resetOwnershipStatus()
  
    self.eventsHandler.updateSubscribedAddresses(self.addresses)
    self.eventsHandler.updateSubscribedChainIDs(self.chainIds)

    self.resetModel()
  
  proc setFilter*(self: Controller, filter: backend_collectibles.CollectibleFilter) =
    if filter == self.filter:
      return

    self.filter = filter

    self.resetModel()

  proc getActivityToken*(self: Controller, id: string): backend_activity.Token =
    return self.model.getActivityToken(id)