import NimQml, Tables, chronicles, sequtils, json, sugar, stint, hashes, strformat, times, strutils
import ../../../app/core/eventemitter
import ../../../app/core/signals/types
import ../../../app/core/tasks/[qt, threadpool]

import dto
import ../network/service as network_service
import ../wallet_account/service as wallet_account_service

import ../../../backend/collectibles as collectibles

include ../../common/json_utils
include async_tasks

export dto

logScope:
  topics = "collectible-service"

# Signals which may be emitted by this service:
const SIGNAL_OWNED_COLLECTIBLES_REFETCH* = "ownedCollectiblesRefetch"
const SIGNAL_OWNED_COLLECTIBLES_UPDATE_STARTED* = "ownedCollectiblesUpdateStarted"
const SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED* = "ownedCollectiblesUpdateFinished"
const SIGNAL_OWNED_COLLECTIBLES_UPDATE_ERROR* = "ownedCollectiblesUpdateError"
const SIGNAL_OWNED_COLLECTIBLES_FROM_WATCHED_CONTRACTS_FETCHED* = "ownedCollectiblesFromWatchedContractsFetched"
const SIGNAL_COLLECTIBLES_UPDATED* = "collectiblesUpdated"

const INVALID_TIMESTAMP* = fromUnix(0)

# Maximum number of owned collectibles to be fetched at a time
const ownedCollectiblesFetchLimit = 100

type
  OwnedCollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    address*: string

type
  CollectiblesUpdateArgs* = ref object of Args
    chainId*: int
    ids*: seq[UniqueID]

type
  OwnedCollectible* = ref object of Args
    id*: UniqueID
    isFromWatchedContract*: bool

proc `$`*(self: OwnedCollectible): string =
  return fmt"""OwnedCollectible(
    id:{self.id}, 
    isFromWatchedContract:{self.isFromWatchedContract}
  )"""

type
  State {.pure.} = enum
    Init,
    WatchedContractsLoading,
    WatchedContractsLoaded,
    ChunkLoading,
    ChunkLoaded,
    AllLoaded,
    Error

type
  CollectiblesData* = ref object
    state*: State
    lastLoadCount*: int
    previousCursor*: string
    nextCursor*: string
    isRefetching*: bool
    lastRefetchTimestamp*: DateTime
    collectibles*: seq[OwnedCollectible]
    collectiblesFromWatchedContracts: seq[OwnedCollectible]
  
proc newCollectiblesData(): CollectiblesData =
  new(result)
  result.state = State.Init
  result.lastLoadCount = 0
  result.previousCursor = ""
  result.nextCursor = ""
  result.isRefetching = true
  result.lastRefetchTimestamp = INVALID_TIMESTAMP.utc()
  result.collectibles = @[]
  result.collectiblesFromWatchedContracts = @[]

proc prepareForRefetch(self: CollectiblesData) =
  self.state = State.Init
  self.lastLoadCount = 0
  self.previousCursor = ""
  self.nextCursor = ""
  self.isRefetching = true

proc isFetching*(self: CollectiblesData): bool =
  result = case self.state:
    of State.WatchedContractsLoading, State.ChunkLoading:
      true
    else:
      false

proc anyLoaded*(self: CollectiblesData): bool =
  return self.lastRefetchTimestamp != INVALID_TIMESTAMP.utc()

proc isError*(self: CollectiblesData): bool =
  return self.state == State.Error

proc allLoaded*(self: CollectiblesData): bool =
  return self.state == State.AllLoaded

proc `$`*(self: CollectiblesData): string =
  return fmt"""CollectiblesData(
    state:{self.state}, 
    lastLoadCount:{self.lastLoadCount}, 
    previousCursor:{self.previousCursor}, 
    nextCursor:{self.nextCursor}, 
    isRefetching:{self.isRefetching}, 
    lastRefetchTimestamp:{self.lastRefetchTimestamp}, 
    collectibles:{self.collectibles}, 
    collectiblesFromWatchedContracts:{self.collectiblesFromWatchedContracts}
  )"""

type
  OwnershipData* = ref object
    data*: CollectiblesData
    watchedContractAddresses*: seq[string]

proc newOwnershipData(): OwnershipData =
  new(result)
  result.data = newCollectiblesData()
  result.watchedContractAddresses = @[]

type
  AddressesData = TableRef[string, OwnershipData]  # [address, OwnershipData]

proc newAddressesData(): AddressesData =
  result = newTable[string, OwnershipData]()

type
  ChainsData = TableRef[int, AddressesData]  # [chainId, AddressesData]

proc newChainsData(): ChainsData =
  result = newTable[int, AddressesData]()

proc contains*(self: ChainsData, chainId: int, address: string): bool =
  return self.hasKey(chainId) and self[chainId].hasKey(address)

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
      accountsOwnershipData: ChainsData
      collectibles: TableRef[int, TableRef[UniqueID, CollectibleDto]]  # [chainId, [UniqueID, CollectibleDto]]
      collections: TableRef[int, TableRef[string, CollectionDto]]  # [chainId, [slug, CollectionDto]]

  # Forward declarations
  proc refetchOwnedCollectibles*(self: Service, chainId: int, address: string)
  proc refetchAllOwnedCollectibles*(self: Service)
  proc removeAddress(self: Service, address: string)

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
    result.accountsOwnershipData = newChainsData()
    result.collectibles = newTable[int, TableRef[UniqueID, CollectibleDto]]()
    result.collections = newTable[int, TableRef[string, CollectionDto]]()

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-tick-reload":
          self.refetchAllOwnedCollectibles()

    self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
      self.removeAddress(AccountDeleted(e).address)

  # needs to be re-written once cache for colletibles works
  proc areCollectionsLoaded*(self: Service, address: string): bool =
    for chainId, adressesData in self.accountsOwnershipData:
      for addressData, ownershipData in adressesData:
        if addressData == address and ownershipData.data.anyLoaded:
          return true
    return false

  proc prepareOwnershipData(self: Service, chainId: int, address: string) =
    if not self.accountsOwnershipData.hasKey(chainId):
      self.accountsOwnershipData[chainId] = newAddressesData()

    let chainData = self.accountsOwnershipData[chainId]
    if not chainData.hasKey(address):
      chainData[address] = newOwnershipData()

  proc processOwnedCollectiblesError(self: Service, chainId: int, address: string) =
    let ownershipData = self.accountsOwnershipData[chainId][address]
    let collectiblesData = ownershipData.data
    collectiblesData.lastLoadCount = 0
    collectiblesData.isRefetching = false
    collectiblesData.state = State.Error

    var data = OwnedCollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_ERROR, data)

  proc updateOwnedCollectibles(self: Service, chainId: int, address: string, previousCursor: string, nextCursor: string, collectibles: seq[CollectibleDto]) =
    let ownershipData = self.accountsOwnershipData[chainId][address]
    let collectiblesData = ownershipData.data
    if not (collectiblesData.nextCursor == previousCursor):
      # Async response from an old fetch request, disregard
      return
    var isFromWatchedContract = false
    case collectiblesData.state:
    of State.WatchedContractsLoading:
      isFromWatchedContract = true
      collectiblesData.state = State.WatchedContractsLoaded
      # All fetched in one go, ignore cursors
      collectiblesData.previousCursor = ""
      collectiblesData.nextCursor = ""
    of State.ChunkLoading:
      if nextCursor == "":
        collectiblesData.state = State.AllLoaded
      else:
        collectiblesData.state = State.ChunkLoaded
      collectiblesData.previousCursor = previousCursor
      collectiblesData.nextCursor = nextCursor
    else:
      let errDescription = collectiblesData.state
      error "Invalid state", errDescription
      self.processOwnedCollectiblesError(chainId, address)

    if collectiblesData.isRefetching:
      collectiblesData.isRefetching = false
      collectiblesData.lastRefetchTimestamp = now()
      collectiblesData.collectibles = @[]
      collectiblesData.collectiblesFromWatchedContracts = @[]

    var count = 0
    for collectible in collectibles:
      let newId = UniqueID(
        contractAddress: collectible.address,
        tokenId: collectible.tokenId
      )
      if not collectiblesData.collectibles.any(c => newId == c.id):
        let ownedCollectible = OwnedCollectible(
          id: newId,
          isFromWatchedContract: isFromWatchedContract
        )
        collectiblesData.collectibles.add(ownedCollectible)
        if isFromWatchedContract:
          collectiblesData.collectiblesFromWatchedContracts.add(ownedCollectible)

        count = count + 1
    collectiblesData.lastLoadCount = count

    var data = OwnedCollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    if (collectiblesData.state == State.WatchedContractsLoaded):
      self.events.emit(SIGNAL_OWNED_COLLECTIBLES_FROM_WATCHED_CONTRACTS_FETCHED, data)
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_FINISHED, data)

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

  proc setWatchedContracts*(self: Service, chainId: int, address: string, contractAddresses: seq[string]) =
    self.prepareOwnershipData(chainId, address)
    self.accountsOwnershipData[chainId][address].watchedContractAddresses = contractAddresses
    # Re-fetch
    self.refetchOwnedCollectibles(chainId, address)

  proc getOwnedCollectibles*(self: Service, chainId: int, addresses: seq[string]) : seq[CollectiblesData] =
    for address in addresses:
      self.prepareOwnershipData(chainId, address)
      result.add(self.accountsOwnershipData[chainId][address].data)

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
    let responseObj = response.parseJson
    let chainIdJson = responseObj["chainId"]
    let chainId = chainIdJson.getInt()

    let errorStr = responseObj["error"].getStr()
    if errorStr != "":
      error "error onRxCollectibles: ", errorStr
    else:
      let (success, collectibles, collections, _, _) = processCollectiblesResult(responseObj)
      if success:
        self.updateCollectiblesCache(chainId, collectibles, collections)
      else:
        let errDesription = "Could not get data from response"
        error "error onRxCollectibles: ", errDesription

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
    let responseObj = response.parseJson
    let chainIdJson = responseObj["chainId"]
    let addressJson = responseObj["address"]
    let chainId = chainIdJson.getInt()
    let address = addressJson.getStr()

    if not self.accountsOwnershipData.contains(chainId, address):
      # Account was removed
      return

    let collectiblesData = self.accountsOwnershipData[chainId][address].data
    
    let errorStr = responseObj["error"].getStr()
    if errorStr != "":
      self.processOwnedCollectiblesError(chainId, address)
      error "error onRxOwnedCollectibles: ", errorStr
    else:
      let (success, collectibles, collections, prevCursor, nextCursor) = processCollectiblesResult(responseObj)
      if success:
        self.updateCollectiblesCache(chainId, collectibles, collections)
        self.updateOwnedCollectibles(chainId, address, prevCursor, nextCursor, collectibles)
      else:
        self.processOwnedCollectiblesError(chainId, address)
        let errDesription = "Could not get data from response"
        error "error onRxOwnedCollectibles: ", errDesription

  proc fetchNextOwnedCollectiblesChunk(self: Service, chainId: int, address: string, limit: int = ownedCollectiblesFetchLimit) =
    self.prepareOwnershipData(chainId, address)

    let ownershipData = self.accountsOwnershipData[chainId][address]
    let collectiblesData = ownershipData.data

    var cursor = collectiblesData.nextCursor

    let arg = FetchOwnedCollectiblesTaskArg(
      tptr: cast[ByteAddress](fetchOwnedCollectiblesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxOwnedCollectibles",
      chainId: chainId,
      address: address,
      cursor: cursor,
      limit: limit
    )
    self.threadpool.start(arg)

  proc onRxOwnedCollectiblesFromWatchedContractAddresses(self: Service, response: string) {.slot.} =
    let responseObj = response.parseJson
    let chainIdJson = responseObj["chainId"]
    let addressJson = responseObj["address"]
    let chainId = chainIdJson.getInt()
    let address = addressJson.getStr()

    if not self.accountsOwnershipData.contains(chainId, address):
      # Account was removed
      return

    let collectiblesData = self.accountsOwnershipData[chainId][address].data

    let errorStr = responseObj["error"].getStr()
    if errorStr != "":
      self.processOwnedCollectiblesError(chainId, address)
      error "error onRxOwnedCollectiblesFromWatchedContractAddresses: ", errorStr
    else:
      let (success, collectibles, collections, prevCursor, nextCursor) = processCollectiblesResult(responseObj)
      if success:
        self.updateCollectiblesCache(chainId, collectibles, collections)
        self.updateOwnedCollectibles(chainId, address, prevCursor, nextCursor, collectibles)
      else:
        self.processOwnedCollectiblesError(chainId, address)
        let errDesription = "Could not get data from response"
        error "error onRxOwnedCollectiblesFromWatchedContractAddresses: ", errDesription

  proc fetchOwnedCollectiblesFromWatchedContracts(self: Service, chainId: int, address: string) =
    let watchedContractAddresses = self.accountsOwnershipData[chainId][address].watchedContractAddresses

    let arg = FetchOwnedCollectiblesFromContractAddressesTaskArg(
      tptr: cast[ByteAddress](fetchOwnedCollectiblesFromContractAddressesTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onRxOwnedCollectiblesFromWatchedContractAddresses",
      chainId: chainId,
      address: address,
      contractAddresses: watchedContractAddresses,
      cursor: "", # Always fetch from the beginning
      limit: 0 # Always fetch the complete list
    )
    self.threadpool.start(arg)

  proc fetchOwnedCollectibles*(self: Service, chainId: int, addresses: seq[string], limit: int = ownedCollectiblesFetchLimit) =
    for address in addresses:
      self.prepareOwnershipData(chainId, address)

      let ownershipData = self.accountsOwnershipData[chainId][address]
      let watchedContractAddresses = ownershipData.watchedContractAddresses
      let collectiblesData = ownershipData.data

      let state = collectiblesData.state

      if state == State.Init and len(watchedContractAddresses) > 0:
        collectiblesData.state = State.WatchedContractsLoading
        self.fetchOwnedCollectiblesFromWatchedContracts(chainId, address)
      elif state == State.Init or state == State.WatchedContractsLoaded or state == State.ChunkLoaded:
        collectiblesData.state = State.ChunkLoading
        self.fetchNextOwnedCollectiblesChunk(chainId, address)
      else:
        return

      var data = OwnedCollectiblesUpdateArgs()
      data.chainId = chainId
      data.address = address
      self.events.emit(SIGNAL_OWNED_COLLECTIBLES_UPDATE_STARTED, data)

  proc refetchOwnedCollectibles*(self: Service, chainId: int, address: string) =
    self.prepareOwnershipData(chainId, address)

    let ownershipData = self.accountsOwnershipData[chainId][address]
    ownershipData.data.prepareForRefetch()

    var data = OwnedCollectiblesUpdateArgs()
    data.chainId = chainId
    data.address = address
    self.events.emit(SIGNAL_OWNED_COLLECTIBLES_REFETCH, data)

    self.fetchOwnedCollectibles(chainId, @[address])

  proc refetchAllOwnedCollectibles*(self: Service) =
    for chainId, addressesData in self.accountsOwnershipData:
      for address, _ in addressesData:
        self.refetchOwnedCollectibles(chainId, address)

  proc removeAddress(self: Service, address: string) =
    for chainId, addressesData in self.accountsOwnershipData:
      addressesData.del(address)
