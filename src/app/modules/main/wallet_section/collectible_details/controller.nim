import NimQml, logging, std/json, sequtils, strutils
import stint

import app/modules/shared_models/collectible_details_entry
import events_handler

import app/core/eventemitter

import backend/collectibles as backend_collectibles
import app_service/service/network/service as network_service

QtObject:
  type
    Controller* = ref object of QObject
      networkService: network_service.Service

      isDetailedEntryLoading: bool
      detailedEntry: CollectibleDetailsEntry

      eventsHandler: EventsHandler

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

    return ExtraData(
      networkShortName: network.shortName,
      networkColor: network.chainColor,
      networkIconUrl: network.iconURL
    )

  proc processGetCollectiblesDetailsResponse(self: Controller, response: JsonNode) =
    defer: self.setIsDetailedEntryLoading(false)

    let res = fromJson(response, backend_collectibles.GetCollectiblesDetailsResponse)

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

    let response = backend_collectibles.getCollectiblesDetailsAsync(@[id])
    if response.error != nil:
      self.setIsDetailedEntryLoading(false)
      error "error fetching collectible details: ", response.error
      return

  proc setupEventHandlers(self: Controller) =
    self.eventsHandler.onGetCollectiblesDetailsDone(proc (jsonObj: JsonNode) =
      self.processGetCollectiblesDetailsResponse(jsonObj)
    )

  proc newController*(networkService: network_service.Service,
    events: EventEmitter
  ): Controller =
    new(result, delete)
    result.networkService = networkService

    result.detailedEntry = newCollectibleDetailsEmptyEntry()
    result.isDetailedEntryLoading = false
  
    result.eventsHandler = newEventsHandler(events)

    result.setup()

    result.setupEventHandlers()
