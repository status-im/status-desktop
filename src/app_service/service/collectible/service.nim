import chronicles, sequtils, json

import dto
import ../network/service as network_service

import ../../../backend/backend

export dto

logScope:
  topics = "collectible-service"

const limit = 200

type
  Service* = ref object of RootObj
    networkService: network_service.Service

proc delete*(self: Service) =
  discard

proc newService*(networkService: network_service.Service): Service =
  result = Service()
  result.networkService = networkService

proc init*(self: Service) =
  discard

proc getCollections*(self: Service, address: string): seq[CollectionDto] =
  try:
    let chainId = self.networkService.getNetworkForCollectibles().chainId
    let response = backend.getOpenseaCollectionsByOwner(chainId, address)
    return map(response.result.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc getCollectibles*(self: Service, address: string, collectionSlug: string): seq[CollectibleDto] =
  try:
    let chainId = self.networkService.getNetworkForCollectibles().chainId
    let response = backend.getOpenseaAssetsByOwnerAndCollection(chainId, address, collectionSlug, limit)
    return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return
