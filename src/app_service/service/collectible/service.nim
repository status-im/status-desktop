import chronicles, sequtils, json

import dto
import ../settings/service as settings_service

import ../../../backend/collectibles as collectibles

export dto

logScope:
  topics = "collectible-service"

const limit = 200

type
  Service* = ref object of RootObj
    settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(settingsService: settings_service.Service): Service =
  result = Service()
  result.settingsService = settingsService

proc init*(self: Service) =
  discard

proc getCollections*(self: Service, address: string): seq[CollectionDto] =
  try:
    let networkId = self.settingsService.getCurrentNetworkId()
    let response = collectibles.getOpenseaCollections(networkId, address)
    return map(response.result.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc getCollectibles*(self: Service, address: string, collectionSlug: string): seq[CollectibleDto] =
  try:
    let networkId = self.settingsService.getCurrentNetworkId()
    let response = collectibles.getOpenseaAssets(networkId, address, collectionSlug, limit)
    return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return
