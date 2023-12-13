import NimQml, logging, std/json, sequtils, strutils
import stint

import app/modules/shared_models/collectibles_entry
import app/modules/shared_models/collectibles_utils
import events_handler

import app/core/eventemitter

import backend/collectibles as backend_collectibles
import app_service/service/network/service as network_service

QtObject:
  type
    Controller* = ref object of QObject
      networkService: network_service.Service

      isDetailedEntryLoading: bool
      detailedEntry: CollectiblesEntry

      eventsHandler: EventsHandler

      requestId: int32

      dataType: backend_collectibles.CollectibleDataType

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc getDetailedEntry*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.detailedEntry)

  proc detailedEntryChanged(self: Controller) {.signal.}

  QtProperty[QVariant] detailedEntry:
    read = getDetailedEntry
    notify = detailedEntryChanged

  proc getIsDetailedEntryLoading*(self: Controller): QVariant {.slot.} =
    return newQVariant(self.detailedEntry)

  proc isDetailedEntryLoadingChanged(self: Controller) {.signal.}

  proc setIsDetailedEntryLoading(self: Controller, value: bool) =
    if self.isDetailedEntryLoading != value:
      self.isDetailedEntryLoading = value
      self.isDetailedEntryLoadingChanged()

  QtProperty[bool] isDetailedEntryLoading:
    read = getIsDetailedEntryLoading
    notify = isDetailedEntryLoadingChanged

  proc getExtraData(self: Controller, chainID: int): ExtraData =
    let network = self.networkService.getNetwork(chainID)
    return getExtraData(network)

  proc processGetCollectiblesDetailsResponse(self: Controller, response: JsonNode) =
    defer: self.setIsDetailedEntryLoading(false)

    let res = fromJson(response, backend_collectibles.GetCollectiblesByUniqueIDResponse)

    if res.errorCode != ErrorCodeSuccess:
      error "error fetching collectible details: ", res.errorCode
      return

    if len(res.collectibles) != 1:
      error "unexpected number of items fetching collectible details: ", len(res.collectibles)
      return

    let collectible = res.collectibles[0]
    let extradata = self.getExtraData(collectible.id.contractID.chainID)

    self.detailedEntry = newCollectibleDetailsFullEntry(collectible, extradata)
    self.detailedEntryChanged()

  proc processCollectiblesDataUpdate(self: Controller, jsonObj: JsonNode) =
      if jsonObj.kind != JArray:
        error "onCollectiblesDataUpdate expected an array"

      for jsonCollectible in jsonObj.getElems():
        let collectible = fromJson(jsonCollectible, backend_collectibles.Collectible)
        self.detailedEntry.updateData(collectible) # Will only update if UniqueID matches

  proc getDetailedCollectible*(self: Controller, chainId: int, contractAddress: string, tokenId: string) {.slot.} =
    self.setIsDetailedEntryLoading(true)

    let id = backend_collectibles.CollectibleUniqueID(
      contractID: backend_collectibles.ContractID(
        chainID: chainId,
        address: contractAddress
      ),
      tokenID: stint.u256(tokenId)
    )
    let extradata = self.getExtraData(chainId)

    self.detailedEntry = newCollectibleDetailsBasicEntry(id, extradata)
    self.detailedEntryChanged()

    let response = backend_collectibles.getCollectiblesByUniqueIDAsync(self.requestId, @[id], self.dataType)
    if response.error != nil:
      self.setIsDetailedEntryLoading(false)
      error "error fetching collectible details: ", response.error
      return

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onGetCollectiblesDetailsDone(proc (jsonObj: JsonNode) =
      self.processGetCollectiblesDetailsResponse(jsonObj)
    )

    self.eventsHandler.onCollectiblesDataUpdate(proc (jsonObj: JsonNode) =
      self.processCollectiblesDataUpdate(jsonObj)
    )

  proc newController*(
    requestId: int32,
    networkService: network_service.Service,
    events: EventEmitter,
    dataType: backend_collectibles.CollectibleDataType = backend_collectibles.CollectibleDataType.Details
  ): Controller =
    new(result, delete)

    result.requestId = requestId

    result.dataType = dataType

    result.networkService = networkService

    result.detailedEntry = newCollectibleDetailsEmptyEntry()
    result.isDetailedEntryLoading = false

    result.eventsHandler = newEventsHandler(result.requestId, events)

    result.setup()

    result.setupEventHandlers()
