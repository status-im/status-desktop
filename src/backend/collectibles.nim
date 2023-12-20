import json, strformat
import stint, Tables, strutils
import core
import response_type, collectibles_types

#import ./core, ./response_type
from ./gen import rpc

export response_type, collectibles_types

type
  CollectiblesRequestID* = enum
    WalletAccount
    ProfileShowcase
    WalletSend

# Declared in services/wallet/collectibles/service.go
const eventCollectiblesOwnershipUpdateStarted*: string = "wallet-collectibles-ownership-update-started"
const eventCollectiblesOwnershipUpdatePartial*: string = "wallet-collectibles-ownership-update-partial"
const eventCollectiblesOwnershipUpdateFinished*: string = "wallet-collectibles-ownership-update-finished"
const eventCollectiblesOwnershipUpdateFinishedWithError*: string = "wallet-collectibles-ownership-update-finished-with-error"
const eventCommunityCollectiblesReceived*: string = "wallet-collectibles-community-collectibles-received"

const eventCollectiblesDataUpdated*: string = "wallet-collectibles-data-updated"
const eventOwnedCollectiblesFilteringDone*: string = "wallet-owned-collectibles-filtering-done"
const eventGetCollectiblesDetailsDone*: string = "wallet-get-collectibles-details-done"

const invalidTimestamp*: int = -1

type
  # Mirrors services/wallet/collectibles/service.go ErrorCode
  ErrorCode* = enum
    ErrorCodeSuccess = 1,
    ErrorCodeTaskCanceled,
    ErrorCodeFailed

  # Mirrors services/wallet/collectibles/service.go OwnershipState
  OwnershipState* = enum
    OwnershipStateIdle = 1,
    OwnershipStateDelayed,
    OwnershipStateUpdating,
    OwnershipStateError

  # Mirrors services/wallet/collectibles/service.go OwnershipState
  OwnershipStatus* = ref object
    state*: OwnershipState
    timestamp*: int

  # Mirrors services/wallet/collectibles/service.go GetOwnedCollectiblesResponse
  GetOwnedCollectiblesResponse* = object
    collectibles*: seq[Collectible]
    offset*: int
    hasMore*: bool
    ownershipStatus*: Table[string, Table[int, OwnershipStatus]]
    errorCode*: ErrorCode

  # Mirrors services/wallet/collectibles/service.go GetCollectiblesByUniqueIDResponse
  GetCollectiblesByUniqueIDResponse* = object
    collectibles*: seq[Collectible]
    errorCode*: ErrorCode

  CommunityCollectiblesReceivedPayload* = object
    collectibles*: seq[Collectible]

  # see status-go/services/wallet/collectibles/filter.go FilterCommunityType
  FilterCommunityType* {.pure.} = enum
    All, OnlyNonCommunity, OnlyCommunity

  # see status-go/services/wallet/collectibles/filter.go Filter
  # All empty sequences mean include all
  CollectibleFilter* = object
    communityIds*: seq[string]
    communityPrivilegesLevels*: seq[int]
    filterCommunity*: FilterCommunityType

  # see status-go/services/wallet/collectibles/service.go FetchType
  FetchType* {.pure.} = enum
    NeverFetch, AlwaysFetch, FetchIfNotCached, FetchIfCacheOld

  # see status-go/services/wallet/collectibles/service.go FetchCriteria
  FetchCriteria* = object
    fetchType*: FetchType
    maxCacheAgeSeconds*: int

# CollectibleOwnershipState
proc `$`*(self: OwnershipStatus): string =
  return fmt"""OwnershipStatus(
    state:{self.state}, 
    timestamp:{self.timestamp}
    """

proc fromJson*(t: JsonNode, T: typedesc[OwnershipStatus]): OwnershipStatus {.inline.} =
    return OwnershipStatus(
        state: OwnershipState(t{"state"}.getInt),
        timestamp: t{"timestamp"}.getInt
    )

# CollectibleFilter
proc newCollectibleFilterAllCommunityIds*(): seq[string] {.inline.} =
  return @[]

proc newCollectibleFilterAllCommunityPrivilegesLevels*(): seq[int] {.inline.} =
  return @[]

proc newCollectibleFilterAllEntries*(): CollectibleFilter {.inline.} =
  return CollectibleFilter(
    communityIds: newCollectibleFilterAllCommunityIds(),
    communityPrivilegesLevels: newCollectibleFilterAllCommunityPrivilegesLevels(),
    filterCommunity: FilterCommunityType.All
  )

proc `$`*(self: CollectibleFilter): string =
  return fmt"""CollectibleFilter(
    communityIds:{self.communityIds}, 
    communityPrivilegesLevels:{self.communityPrivilegesLevels}, 
    filterCommunity:{self.filterCommunity}
    """

proc `%`*(t: CollectibleFilter): JsonNode {.inline.} =
  result = newJObject()
  result["community_ids"] = %(t.communityIds)
  result["community_privileges_levels"] = %(t.communityPrivilegesLevels)
  result["filter_community"] = %(t.filterCommunity.int)
  
proc `%`*(t: ref CollectibleFilter): JsonNode {.inline.} =
  return %(t[])

# CollectibleDataType
proc `%`*(t: CollectibleDataType): JsonNode {.inline.} =
  result = %(t.int)

proc `%`*(t: ref CollectibleDataType): JsonNode {.inline.} =
  return %(t[])

# FetchCriteria
proc `$`*(self: FetchCriteria): string =
  return fmt"""FetchCriteria(
    fetchType:{self.fetchType}, 
    maxCacheAgeSeconds:{self.maxCacheAgeSeconds}
    """

proc `%`*(t: FetchCriteria): JsonNode {.inline.} =
  result = newJObject()
  result["fetch_type"] = %(t.fetchType.int)
  result["max_cache_age_seconds"] = %(t.maxCacheAgeSeconds)

proc `%`*(t: ref FetchCriteria): JsonNode {.inline.} =
  return %(t[])

# Responses
proc fromJson*(e: JsonNode, T: typedesc[GetOwnedCollectiblesResponse]): GetOwnedCollectiblesResponse {.inline.} =
  var collectibles: seq[Collectible]
  if e.hasKey("collectibles"):
    let jsonCollectibles = e["collectibles"]
    for jsonCollectible in jsonCollectibles.getElems():
      let collectible = fromJson(jsonCollectible, Collectible)
      collectibles.add(collectible)

  var ownershipStatus = initTable[string, Table[int, OwnershipStatus]]()
  if e.hasKey("ownershipStatus"):
    let jsonOwnershipStatus = e["ownershipStatus"]
    for address, jsonStatusPerChain in jsonOwnershipStatus.getFields():
      var statusPerChain = initTable[int, OwnershipStatus]()
      for chainId, jsonStatus in jsonStatusPerChain.getFields():
        statusPerChain[parseInt(chainId)] = fromJson(jsonStatus, OwnershipStatus)
      ownershipStatus[address] = statusPerChain

  result = T(
    collectibles: collectibles,
    offset: e["offset"].getInt(),
    hasMore: if e.hasKey("hasMore"): e["hasMore"].getBool()
                      else: false,
    ownershipStatus: ownershipStatus,
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

proc fromJson*(e: JsonNode, T: typedesc[GetCollectiblesByUniqueIDResponse]): GetCollectiblesByUniqueIDResponse {.inline.} =
  var collectibles: seq[Collectible] = @[]
  for item in e["collectibles"].getElems():
    collectibles.add(fromJson(item, Collectible))

  result = T(
    collectibles: collectibles,
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

proc fromJson*(e: JsonNode, T: typedesc[CommunityCollectiblesReceivedPayload]): CommunityCollectiblesReceivedPayload {.inline.} =
  var collectibles: seq[Collectible] = @[]
  for item in e.getElems():
    collectibles.add(fromJson(item, Collectible))

  result = T(
    collectibles: collectibles
  )

rpc(getCollectiblesByOwnerWithCursor, "wallet"):
  chainId: int
  address: string
  cursor: string
  limit: int

rpc(getCollectiblesByOwnerAndContractAddressWithCursor, "wallet"):
  chainId: int
  address: string
  contractAddresses: seq[string]
  cursor: string
  limit: int

rpc(getCollectiblesByUniqueID, "wallet"):
  uniqueIds: seq[CollectibleUniqueID]

rpc(getCollectibleOwnersByContractAddress, "wallet"):
  chainId: int
  contractAddress: string

rpc(getOwnedCollectiblesAsync, "wallet"):
  requestId: int32
  chainIDs: seq[int]
  addresses: seq[string]
  filter: CollectibleFilter
  offset: int
  limit: int
  dataType: CollectibleDataType
  fetchCriteria: FetchCriteria

rpc(getCollectiblesByUniqueIDAsync, "wallet"):
  requestId: int32
  uniqueIds: seq[CollectibleUniqueID]
  dataType: CollectibleDataType

rpc(refetchOwnedCollectibles, "wallet"):
  discard
