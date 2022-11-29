import NimQml, chronicles, sequtils, json
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import dto
import ../network/service as network_service

import ../../../backend/backend

include ../../common/json_utils
include async_tasks

export dto

logScope:
  topics = "collectible-service"

const limit = 200

const GetCollections* = "get-collections"

type
  GetCollectionsArgs* = ref object of Args
    chainId*: int
    address*: string
    collections*: seq[CollectionDto]

const GetCollectibles* = "get-collectibles"

type
  GetCollectiblesArgs* = ref object of Args
    chainId*: int
    address*: string
    collectionSlug*: string
    collectibles*: seq[CollectibleDto]
    error*: string

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      networkService: network_service.Service

  proc delete*(self: Service) =
      self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService

  proc init*(self: Service) =
    discard

  proc getNetwork*(self: Service): NetworkDto =
    return self.networkService.getNetworkForCollectibles()

  proc onGetCollections*(self: Service, response: string) {.slot.} =
    var data = GetCollectionsArgs()
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        let addressJson = responseObj["address"]

        let validAccount = (chainIdJson.kind == JInt and 
          addressJson.kind == JString)
        if (validAccount):
          data.chainId = chainIdJson.getInt()
          data.address = addressJson.getStr()

          let collectionsJson = responseObj["collections"]
          if (collectionsJson.kind == JArray):
            data.collections = map(collectionsJson.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
    except Exception as e:
      let errDesription = e.msg
      error "error onGetCollections: ", errDesription
    self.events.emit(GetCollections, data)

  proc getCollectionsAsync*(self: Service, address: string) =
    let arg = GetCollectionsTaskArg(
      tptr: cast[ByteAddress](getCollectionsTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGetCollections",
      chainId: self.getNetwork().chainId,
      address: address,
    )
    self.threadpool.start(arg)
  
  proc onGetCollectibles*(self: Service, response: string) {.slot.} =
    var data = GetCollectiblesArgs()
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        let addressJson = responseObj["address"]
        let collectionSlugJson = responseObj["collectionSlug"]
        
        let validCollection = (chainIdJson.kind == JInt and 
          addressJson.kind == JString and 
          collectionSlugJson.kind == JString)
        if (validCollection):
          data.chainId = chainIdJson.getInt()
          data.address = addressJson.getStr()
          data.collectionSlug = collectionSlugJson.getStr()

          let collectiblesJson = responseObj["collectibles"]
          if (collectiblesJson.kind == JArray):
            data.collectibles = map(collectiblesJson.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
    except Exception as e:
      let errDesription = e.msg
      error "error onGetCollectibles: ", errDesription
    self.events.emit(GetCollectibles, data)

  proc getCollectiblesAsync*(self: Service, address: string, collectionSlug: string) =
    let arg = GetCollectiblesTaskArg(
      tptr: cast[ByteAddress](getCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGetCollectibles",
      chainId: self.getNetwork().chainId,
      address: address,
      collectionSlug: collectionSlug,
      limit: limit
    )
    self.threadpool.start(arg)
