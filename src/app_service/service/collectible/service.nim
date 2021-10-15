import chronicles, sequtils, json

import ./service_interface, ./dto
import status/statusgo_backend_new/collectibles as collectibles

export service_interface

const limit = 200

logScope:
  topics = "collectible-service"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method getCollections(self: Service, chainId: int, address: string): seq[CollectionDto] =
  try:
    let response = collectibles.getOpenseaCollections(chainId, address)
    return map(response.result.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getCollectibles(self: Service, chainId: int, address: string, collectionSlug: string): seq[CollectibleDto] =
  try:
    let response = collectibles.getOpenseaAssets(chainId, address, collectionSlug, limit)
    return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return