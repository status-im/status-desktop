import NimQml, Tables, chronicles, sequtils, json, sugar, stint, hashes
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import dto
import ../network/service as network_service

import ../../../backend/collectibles as collectibles

include ../../common/json_utils
include async_tasks

export dto

logScope:
  topics = "collectible-service"

# Signals which may be emitted by this service:
const SIGNAL_OWNED_COLLECTIONS_UPDATED* = "ownedCollectionsUpdated"
const SIGNAL_OWNED_COLLECTIBLES_UPDATED* = "ownedCollectiblesUpdated"
const SIGNAL_COLLECTIBLES_UPDATED* = "collectiblesUpdated"

# Maximum number of collectibles to be fetched at a time
const limit = 200 

# Unique identifier for collectible in a specific chain
type
  UniqueID* = object
    contractAddress*: string
    tokenId*: UInt256

type
  OwnedCollectionsUpdateArgs* = ref object of Args
    chainId*: int
    address*: string

type
  OwnedCollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    address*: string
    collectionSlug*: string

type
  CollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    ids*: seq[UniqueID]

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

proc hash(x: UniqueID): Hash =
  result = x.contractAddress.hash !& x.tokenId.hash
  result = !$result

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      networkService: network_service.Service
      ownershipData: ChainsData
      data: TableRef[int, TableRef[UniqueID, CollectibleDto]]  # [chainId, [UniqueID, CollectibleDto]]

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
    result.ownershipData = newTable[int, AdressesData]()
    result.data = newTable[int, TableRef[UniqueID, CollectibleDto]]()

  proc init*(self: Service) =
    discard

  proc insertAddressIfNeeded*(self: Service, chainId: int, address: string) =
    if not self.ownershipData.hasKey(chainId):
      self.ownershipData[chainId] = newTable[string, CollectionsData]()

    let chainData = self.ownershipData[chainId]
    if not chainData.hasKey(address):
      chainData[address] = newCollectionsData()

  proc updateOwnedCollectionsCache*(self: Service, chainId: int, address: string, collections: seq[CollectionDto]) =
    try:
      let oldAddressData = self.ownershipData[chainId][address]

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
      self.ownershipData[chainId][address] = newAddressData

      var data = OwnedCollectionsUpdateArgs()
      data.chainId = chainId
      data.address = address
      
      self.events.emit(SIGNAL_OWNED_COLLECTIONS_UPDATED, data)

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc updateOwnedCollectiblesCache*(self: Service, chainId: int, address: string, collectionSlug: string, collectibles: seq[CollectibleDto]) =
    try:
      let collection = self.ownershipData[chainId][address].collections[collectionSlug]
      collection.collectibles.clear()

      for collectible in collectibles:
        collection.collectibles[collectible.id] = collectible
      collection.collectiblesLoaded = true

      var data = OwnedCollectiblesUpdateArgs()
      data.chainId = chainId
      data.address = address
      data.collectionSlug = collectionSlug
      self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATED, data)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc updateCollectiblesCache*(self: Service, chainId: int, collectibles: seq[CollectibleDto]) =
    if not self.data.hasKey(chainId):
      self.data[chainId] = newTable[UniqueID, CollectibleDto]()
    
    var data = CollectiblesUpdateArgs()
    data.chainId = chainId

    for collectible in collectibles:
      let id = UniqueID(
        contractAddress: collectible.address,
        tokenId: collectible.tokenId
      )
      self.data[chainId][id] = collectible
      data.ids.add(id)
    
    self.events.emit(SIGNAL_COLLECTIBLES_UPDATED, data)

  proc getOwnedCollections*(self: Service, chainId: int, address: string) : CollectionsData =
    try:
      return self.ownershipData[chainId][address]
    except:
      discard
    return newCollectionsData()

  proc getOwnedCollection*(self: Service, chainId: int, address: string, collectionSlug: string) : CollectionData =
    try:
      return self.ownershipData[chainId][address].collections[collectionSlug]
    except:
      discard
    return newCollectionData(CollectionDto())

  proc getCollectible*(self: Service, chainId: int, id: UniqueID) : CollectibleDto =
    try:
      return self.data[chainId][id]
    except:
      discard
    return newCollectibleDto()

  proc onRxCollectibles*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        let collectiblesJson = responseObj["collectibles"]

        if (chainIdJson.kind == JInt and
          collectiblesJson.kind == JArray):
          let chainId = chainIdJson.getInt()
          let collectibles = map(collectiblesJson.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
          self.updateCollectiblesCache(chainId, collectibles)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxCollectibles: ", errDescription

  proc fetchCollectibles*(self: Service, chainId: int, ids: seq[UniqueID]) =
    let arg = FetchCollectiblesTaskArg(
      tptr: cast[ByteAddress](fetchCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxCollectibles",
      chainId: chainId,
      ids: ids.map(id => collectibles.NFTUniqueID(
        contractAddress: id.contractAddress,
        tokenID: id.tokenId.toString()
      )),
      limit: limit
    )
    self.threadpool.start(arg)

  proc onRxOwnedCollections*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        let addressJson = responseObj["address"]

        let validAccount = (chainIdJson.kind == JInt and 
          addressJson.kind == JString)
        if (validAccount):
          let chainId = chainIdJson.getInt()
          let address = addressJson.getStr()

          var collections: seq[CollectionDto]
          let collectionsJson = responseObj["collections"]
          if (collectionsJson.kind == JArray):
            collections = map(collectionsJson.getElems(), proc(x: JsonNode): CollectionDto = x.toCollectionDto())

          self.updateOwnedCollectionsCache(chainId, address, collections)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxOwnedCollections: ", errDescription

  proc fetchOwnedCollections*(self: Service, chainId: int, address: string) =
    self.insertAddressIfNeeded(chainId, address)

    let arg = FetchOwnedCollectionsTaskArg(
      tptr: cast[ByteAddress](fetchOwnedCollectionsTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxOwnedCollections",
      chainId: chainId,
      address: address,
    )
    self.threadpool.start(arg)
  
  proc onRxOwnedCollectibles*(self: Service, response: string) {.slot.} =
    var data = OwnedCollectiblesUpdateArgs()
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
          let chainId = chainIdJson.getInt()
          let address = addressJson.getStr()
          let collectionSlug = collectionSlugJson.getStr()

          var collectibles: seq[CollectibleDto]
          let collectiblesJson = responseObj["collectibles"]
          if (collectiblesJson.kind == JArray):
            collectibles = map(collectiblesJson.getElems(), proc(x: JsonNode): CollectibleDto = x.toCollectibleDto())
          self.updateOwnedCollectiblesCache(chainId, address, collectionSlug, collectibles)
          self.updateCollectiblesCache(data.chainId, collectibles)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxOwnedCollectibles: ", errDescription

  proc fetchOwnedCollectibles*(self: Service, chainId: int, address: string, collectionSlug: string) =
    self.insertAddressIfNeeded(chainId, address)
    let collections = self.ownershipData[chainId][address].collections

    if not collections.hasKey(collectionSlug):
      error "error fetchOwnedCollectibles: Attempting to fetch collectibles from unknown collection: ", collectionSlug
      return

    let arg = FetchOwnedCollectiblesTaskArg(
      tptr: cast[ByteAddress](fetchOwnedCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxOwnedCollectibles",
      chainId: chainId,
      address: address,
      collectionSlug: collectionSlug,
      limit: limit
    )
    self.threadpool.start(arg)

  proc fetchAllOwnedCollectibles*(self: Service, chainId: int, address: string) =
    try:
      for collectionSlug, _ in self.ownershipData[chainId][address].collections:
        self.fetchOwnedCollectibles(chainId, address, collectionSlug)
    except Exception as e:
      let errDescription = e.msg
      error "error fetchAllOwnedCollectibles: ", errDescription
