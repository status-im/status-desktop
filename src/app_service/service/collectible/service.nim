import chronicles, sequtils, json

import ./service_interface, ./dto
import ../setting/service as setting_service

import status/statusgo_backend_new/collectibles as collectibles

export service_interface

const limit = 200

logScope:
  topics = "collectible-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.ServiceInterface): Service =
  result = Service()
  result.settingService = settingService

method init*(self: Service) =
  discard

method getCollections(self: Service, address: string): seq[CollectionDto] =
  try:
    let networkId = self.settingService.getSetting().currentNetwork.id
    let response = collectibles.getOpenseaCollections(networkId, address)
    return map(response.result.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getCollectibles(self: Service, address: string, collectionSlug: string): seq[CollectibleDto] =
  try:
    let networkId = self.settingService.getSetting().currentNetwork.id
    let response = collectibles.getOpenseaAssets(networkId, address, collectionSlug, limit)
    return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return