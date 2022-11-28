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
    collections*: seq[CollectionDto]

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

  proc onGetCollections*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj.kind != JArray):
        self.events.emit(GetCollections, GetCollectionsArgs())
        return
      
      let collections = map(responseObj.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
      self.events.emit(GetCollections, GetCollectionsArgs(collections: collections))
    except:
      self.events.emit(GetCollections, GetCollectionsArgs())

  proc getCollectionsAsync*(self: Service, address: string) =
    let arg = GetCollectionsTaskArg(
      tptr: cast[ByteAddress](getCollectionsTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGetCollections",
      chainId: self.networkService.getNetworkForCollectibles().chainId,
      address: address,
    )
    self.threadpool.start(arg)

  proc getNetwork*(self: Service): NetworkDto =
    return self.networkService.getNetworkForCollectibles()
  
  proc getCollectibles*(self: Service, address: string, collectionSlug: string): seq[CollectibleDto] =
    try:
      let chainId = self.getNetwork().chainId
      let response = backend.getOpenseaAssetsByOwnerAndCollection(chainId, address, collectionSlug, limit)
      return map(response.result.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return
