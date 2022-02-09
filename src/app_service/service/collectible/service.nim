import chronicles, sequtils, json

import ./service_interface, ./dto
import ../settings/service_interface as settings_service

import ../../../backend/collectibles as collectibles

export service_interface

const limit = 200

logScope:
  topics = "collectible-service"

type
  Service* = ref object of service_interface.ServiceInterface
    settingsService: settings_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(settingsService: settings_service.ServiceInterface): Service =
  result = Service()
  result.settingsService = settingsService

method init*(self: Service) =
  discard

method getCollections(self: Service, address: string): seq[CollectionDto] =
  try:
    let networkId = self.settingsService.getCurrentNetworkId()
    let response = collectibles.getOpenseaCollections(networkId, address)
    return map(response.result.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getCollectibles(self: Service, address: string, collectionSlug: string): seq[CollectibleDto] =
  try:
    let networkId = self.settingsService.getCurrentNetworkId()
    let response = collectibles.getOpenseaAssets(networkId, address, collectionSlug, limit)
    return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return
