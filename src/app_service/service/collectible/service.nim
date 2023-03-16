import NimQml, Tables, chronicles, sequtils, json, sugar, stint, hashes, strformat, times
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
const SIGNAL_OWNED_COLLECTIBLES_UPDATE_STARTED* = "ownedCollectiblesUpdateStarted"
const SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED* = "ownedCollectiblesUpdateFinished"
const SIGNAL_COLLECTIBLES_UPDATED* = "collectiblesUpdated"

type
  OwnedCollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    address*: string

type
  CollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    ids*: seq[UniqueID]

type
  CollectiblesData* = ref object
    isFetching*: bool
    allLoaded*: bool
    lastLoadWasFromStart*: bool
    lastLoadFromStartTimestamp*: DateTime
    lastLoadCount*: int
    previousCursor*: string
    nextCursor*: string
    ids*: seq[UniqueID]
  
proc newCollectiblesData*(): CollectiblesData =
  new(result)
  result.isFetching = false
  result.allLoaded = false
  result.lastLoadWasFromStart = false
  result.lastLoadFromStartTimestamp = now() - initDuration(weeks = 1)
  result.lastLoadCount = 0
  result.previousCursor = ""
  result.nextCursor = ""
  result.ids = @[]

proc `$`*(self: CollectiblesData): string =
  return fmt"""CollectiblesData(
    isFetching:{self.isFetching}, 
    allLoaded:{self.allLoaded}, 
    lastLoadWasFromStart:{self.lastLoadWasFromStart},
    lastLoadFromStartTimestamp:{self.lastLoadFromStartTimestamp},
    lastLoadCount:{self.lastLoadCount}, 
    previousCursor:{self.previousCursor}, 
    nextCursor:{self.nextCursor}, 
    ids:{self.ids}
  )"""

type
  AdressesData = TableRef[string, CollectiblesData]  # [address, CollectiblesData]

type
  ChainsData = TableRef[int, AdressesData]  # [chainId, AdressesData]

type
  CollectiblesResult = tuple[success: bool, collectibles: seq[CollectibleDto], collections: seq[CollectionDto], previousCursor: string, nextCursor: string]

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
      collectibles: TableRef[int, TableRef[UniqueID, CollectibleDto]]  # [chainId, [UniqueID, CollectibleDto]]
      collections: TableRef[int, TableRef[string, CollectionDto]]  # [chainId, [slug, CollectionDto]]

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
    result.collectibles = newTable[int, TableRef[UniqueID, CollectibleDto]]()
    result.collections = newTable[int, TableRef[string, CollectionDto]]()

  proc init*(self: Service) =
    discard

  proc prepareOwnershipData(self: Service, chainId: int, address: string, reset: bool = false) =
    if not self.ownershipData.hasKey(chainId):
      self.ownershipData[chainId] = newTable[string, CollectiblesData]()

    let chainData = self.ownershipData[chainId]
    if reset or not chainData.hasKey(address):
      chainData[address] = newCollectiblesData()

    let addressData = self.ownershipData[chainId][address]
    addressData.lastLoadWasFromStart = reset
    if reset:
      addressData.lastLoadFromStartTimestamp = now()


  proc updateOwnedCollectibles(self: Service, chainId: int, address: string, previousCursor: string, nextCursor: string, collectibles: seq[CollectibleDto]) =
    try:
      let collectiblesData = self.ownershipData[chainId][address]
      collectiblesData.previousCursor = previousCursor
      collectiblesData.nextCursor = nextCursor
      collectiblesData.allLoaded = (nextCursor == "")

      var count = 0
      for collectible in collectibles:
        let newId = UniqueID(
          contractAddress: collectible.address,
          tokenId: collectible.tokenId
        )
        if not collectiblesData.ids.any(id => newId == id):
          collectiblesData.ids.add(newId)
          count = count + 1
      collectiblesData.lastLoadCount = count
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc updateCollectiblesCache*(self: Service, chainId: int, collectibles: seq[CollectibleDto], collections: seq[CollectionDto]) =
    if not self.collectibles.hasKey(chainId):
      self.collectibles[chainId] = newTable[UniqueID, CollectibleDto]()
    
    if not self.collections.hasKey(chainId):
      self.collections[chainId] = newTable[string, CollectionDto]()
  
    var data = CollectiblesUpdateArgs()
    data.chainId = chainId

    for collection in collections:
      let slug = collection.slug
      self.collections[chainId][slug] = collection


    for collectible in collectibles:
      let id = UniqueID(
        contractAddress: collectible.address,
        tokenId: collectible.tokenId
      )
      self.collectibles[chainId][id] = collectible
      data.ids.add(id)
    
    self.events.emit(SIGNAL_COLLECTIBLES_UPDATED, data)

  proc getOwnedCollectibles*(self: Service, chainId: int, address: string) : CollectiblesData =
    try:
      return self.ownershipData[chainId][address]
    except:
      discard
    return newCollectiblesData()

  proc getCollectible*(self: Service, chainId: int, id: UniqueID) : CollectibleDto =
    try:
      return self.collectibles[chainId][id]
    except:
      discard
    return newCollectibleDto()

  proc getCollection*(self: Service, chainId: int, slug: string) : CollectionDto =
    try:
      return self.collections[chainId][slug]
    except:
      discard
    return newCollectionDto()

  proc processCollectiblesResult(responseObj: JsonNode) : CollectiblesResult =
    result.success = false
    let collectiblesContainerJson = responseObj["collectibles"]
    if collectiblesContainerJson.kind == JObject:
      let previousCursorJson = collectiblesContainerJson["previous"]
      let nextCursorJson = collectiblesContainerJson["next"]
      let collectiblesJson = collectiblesContainerJson["assets"]

      if previousCursorJson.kind == JString and nextCursorJson.kind == JString:
        result.previousCursor = previousCursorJson.getStr()
        result.nextCursor = nextCursorJson.getStr()
        for collectibleJson in collectiblesJson.getElems():
          if collectibleJson.kind == JObject:
            result.collectibles.add(collectibleJson.toCollectibleDto())
            let collectionJson = collectibleJson["collection"]
            if collectionJson.kind == JObject:
              result.collections.add(collectionJson.toCollectionDto())
            else:
              return
          else:
            return
        result.success = true

  proc onRxCollectibles(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        if chainIdJson.kind == JInt:
          let chainId = chainIdJson.getInt()
          let (success, collectibles, collections, _, _) = processCollectiblesResult(responseObj)
          if success:
            self.updateCollectiblesCache(chainId, collectibles, collections)
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
      limit: len(ids)
    )
    self.threadpool.start(arg)
  
  proc onRxOwnedCollectibles(self: Service, response: string) {.slot.} =
    var data = OwnedCollectiblesUpdateArgs()
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):
        let chainIdJson = responseObj["chainId"]
        let addressJson = responseObj["address"]
        if (chainIdJson.kind == JInt and
          addressJson.kind == JString):
          data.chainId = chainIdJson.getInt()
          data.address = addressJson.getStr()
          self.ownershipData[data.chainId][data.address].isFetching = false
          let (success, collectibles, collections, prevCursor, nextCursor) = processCollectiblesResult(responseObj)
          if success:
            self.updateCollectiblesCache(data.chainId, collectibles, collections)
            self.updateOwnedCollectibles(data.chainId, data.address, prevCursor, nextCursor, collectibles)
    except Exception as e:
      let errDescription = e.msg
      error "error onRxOwnedCollectibles: ", errDescription
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED, data)

  proc resetOwnedCollectibles*(self: Service, chainId: int, address: string) =
    self.prepareOwnershipData(chainId, address, true)
    var data = OwnedCollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED, data)

  proc fetchOwnedCollectibles*(self: Service, chainId: int, address: string, limit: int) =
    self.prepareOwnershipData(chainId, address, false)

    let collectiblesData = self.ownershipData[chainId][address]

    if collectiblesData.isFetching:
      return

    if collectiblesData.allLoaded:
      return

    collectiblesData.isFetching = true

    var data = OwnedCollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_STARTED, data)

    let arg = FetchOwnedCollectiblesTaskArg(
      tptr: cast[ByteAddress](fetchOwnedCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxOwnedCollectibles",
      chainId: chainId,
      address: address,
      cursor: collectiblesData.nextCursor,
      limit: limit
    )
    self.threadpool.start(arg)
