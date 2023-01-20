import NimQml, Tables, chronicles, sequtils, json, sugar
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

# Signals which may be emitted by this service:
const SIGNAL_COLLECTIONS_UPDATE_STARTED* = "collectionsUpdateStarted"
const SIGNAL_COLLECTIONS_UPDATED* = "collectionsUpdated"
const SIGNAL_COLLECTIBLES_UPDATE_STARTED* = "collectiblesUpdateStarted"
const SIGNAL_COLLECTIBLES_UPDATED* = "collectiblesUpdated"

# Maximum number of collectibles to be fetched at a time
const limit = 200 

type
  CollectionsUpdateArgs* = ref object of Args
    chainId*: int
    address*: string

type
  CollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    address*: string
    collectionSlug*: string

type
  CollectionData* = ref object
    collection*: CollectionDto
    collectiblesLoaded*: bool
    collectibles*: OrderedTableRef[int, CollectibleDto]  # [collectibleId, CollectibleDto]

proc newCollectionData*(collection: CollectionDto): CollectionData =
  new(result)
  result.collection = collection
  result.collectiblesLoaded = false
  result.collectibles = newOrderedTable[int, CollectibleDto]()

type
  CollectionsData* = ref object
    collectionsLoaded*: bool
    collections*: OrderedTableRef[string, CollectionData]  # [collectionSlug, CollectionData]
  
proc newCollectionsData*(): CollectionsData =
  new(result)
  result.collectionsLoaded = false
  result.collections = newOrderedTable[string, CollectionData]()

type
  AdressesData* = TableRef[string, CollectionsData]  # [address, CollectionsData]

type
  ChainsData* = TableRef[int, AdressesData]  # [chainId, AdressesData]

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      networkService: network_service.Service
      data: ChainsData

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
    result.data = newTable[int, AdressesData]()

  proc init*(self: Service) =
    discard

  proc insertAddressIfNeeded*(self: Service, chainId: int, address: string) =
    if not self.data.hasKey(chainId):
      self.data[chainId] = newTable[string, CollectionsData]()

    let chainData = self.data[chainId]
    if not chainData.hasKey(address):
      chainData[address] = newCollectionsData()

  proc setCollections*(self: Service, chainId: int, address: string, collections: seq[CollectionDto]) =
    try:
      let oldAddressData = self.data[chainId][address]

      # Start with empty object. Only add newly received collections, so removed ones are discarded
      let newAddressData = newCollectionsData()
      for collection in collections:
        newAddressData.collections[collection.slug] = newCollectionData(collection)
        if oldAddressData.collections.hasKey(collection.slug):
          let oldCollection = oldAddressData.collections[collection.slug]
          let newCollection = newAddressData.collections[collection.slug]
          # Take collectibles from old collection
          newCollection.collectiblesLoaded = oldCollection.collectiblesLoaded
          newCollection.collectibles = oldCollection.collectibles

      newAddressData.collectionsLoaded = true
      self.data[chainId][address] = newAddressData
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc setCollectibles*(self: Service, chainId: int, address: string, collectionSlug: string, collectibles: seq[CollectibleDto]) =
    try:
      let collection = self.data[chainId][address].collections[collectionSlug]
      collection.collectibles.clear()

      for collectible in collectibles:
        collection.collectibles[collectible.id] = collectible
      collection.collectiblesLoaded = true
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc getCollections*(self: Service, chainId: int, address: string) : CollectionsData =
    try:
      return self.data[chainId][address]
    except:
      discard
    return newCollectionsData()

  proc getCollection*(self: Service, chainId: int, address: string, collectionSlug: string) : CollectionData =
    try:
      return self.data[chainId][address].collections[collectionSlug]
    except:
      discard
    return newCollectionData(CollectionDto())

  proc getCollectible*(self: Service, chainId: int, address: string, collectionSlug: string, collectibleId: int) : CollectibleDto =
    try:
      return self.data[chainId][address].collections[collectionSlug].collectibles[collectibleId]
    except:
      discard
    return CollectibleDto()

  proc onRxCollections*(self: Service, response: string) {.slot.} =
    var data = CollectionsUpdateArgs()
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

          var collections: seq[CollectionDto]
          let collectionsJson = responseObj["collections"]
          if (collectionsJson.kind == JArray):
            collections = map(collectionsJson.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())
          self.setCollections(data.chainId, data.address, collections)
          self.events.emit(SIGNAL_COLLECTIONS_UPDATED, data)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxCollections: ", errDescription

  proc fetchCollections*(self: Service, chainId: int, address: string) =
    self.insertAddressIfNeeded(chainId, address)

    var data = CollectionsUpdateArgs()
    data.chainId = chainId
    data.address = address
    self.events.emit(SIGNAL_COLLECTIONS_UPDATE_STARTED, data)

    let arg = FetchCollectionsTaskArg(
      tptr: cast[ByteAddress](fetchCollectionsTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxCollections",
      chainId: chainId,
      address: address,
    )
    self.threadpool.start(arg)
  
  proc onRxCollectibles*(self: Service, response: string) {.slot.} =
    var data = CollectiblesUpdateArgs()
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

          var collectibles: seq[CollectibleDto]
          let collectiblesJson = responseObj["collectibles"]
          if (collectiblesJson.kind == JArray):
            collectibles = map(collectiblesJson.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
          self.setCollectibles(data.chainId, data.address, data.collectionSlug, collectibles)
          self.events.emit(SIGNAL_COLLECTIBLES_UPDATED, data)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxCollectibles: ", errDescription

  proc fetchCollectibles*(self: Service, chainId: int, address: string, collectionSlug: string) =
    self.insertAddressIfNeeded(chainId, address)
    let collections = self.data[chainId][address].collections

    if not collections.hasKey(collectionSlug):
      error "error fetchCollectibles: Attempting to fetch collectibles from unknown collection: ", collectionSlug
      return

    var data = CollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    data.collectionSlug = collectionSlug
    self.events.emit(SIGNAL_COLLECTIBLES_UPDATE_STARTED, data)

    let arg = FetchCollectiblesTaskArg(
      tptr: cast[ByteAddress](fetchCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxCollectibles",
      chainId: chainId,
      address: address,
      collectionSlug: collectionSlug,
      limit: limit
    )
    self.threadpool.start(arg)

  proc fetchAllCollectibles*(self: Service, chainId: int, address: string) =
    try:
      for collectionSlug, _ in self.data[chainId][address].collections:
        self.fetchCollectibles(chainId, address, collectionSlug)
    except Exception as e:
      let errDescription = e.msg
      error "error fetchAllCollectibles: ", errDescription
