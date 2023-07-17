import json, json_serialization, strformat
import stint, Tables
import core
import response_type, collectibles_types

#import ./core, ./response_type
from ./gen import rpc

export response_type, collectibles_types

# Declared in services/wallet/collectibles/service.go
const eventCollectiblesOwnershipUpdateStarted*: string = "wallet-collectibles-ownership-update-started"
const eventCollectiblesOwnershipUpdateFinished*: string = "wallet-collectibles-ownership-update-finished"
const eventCollectiblesOwnershipUpdateFinishedWithError*: string = "wallet-collectibles-ownership-update-finished-with-error"

const eventOwnedCollectiblesFilteringDone*: string = "wallet-owned-collectibles-filtering-done"
const eventGetCollectiblesDataDone*: string = "wallet-get-collectibles-data-done"

type
  # Mirrors services/wallet/collectibles/service.go ErrorCode
  ErrorCode* = enum
    ErrorCodeSuccess = 1,
    ErrorCodeTaskCanceled,
    ErrorCodeFailed

  # Mirrors services/wallet/collectibles/service.go FilterOwnedCollectiblesResponse
  FilterOwnedCollectiblesResponse* = object
    collectibles*: seq[CollectibleHeader]
    offset*: int
    hasMore*: bool
    errorCode*: ErrorCode

  # Mirrors services/wallet/collectibles/service.go GetCollectiblesDataResponse
  GetCollectiblesDataResponse* = object
    collectibles*: seq[CollectibleData]
    errorCode*: ErrorCode


# Responses
proc fromJson*(e: JsonNode, T: typedesc[FilterOwnedCollectiblesResponse]): FilterOwnedCollectiblesResponse {.inline.} =
  var collectibles: seq[CollectibleHeader]
  if e.hasKey("collectibles"):
    let jsonCollectibles = e["collectibles"]
    collectibles = newSeq[CollectibleHeader](jsonCollectibles.len)
    for i in 0 ..< jsonCollectibles.len:
      collectibles[i] = fromJson(jsonCollectibles[i], CollectibleHeader)

  result = T(
    collectibles: collectibles,
    offset: e["offset"].getInt(),
    hasMore: if e.hasKey("hasMore"): e["hasMore"].getBool()
                      else: false,
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

proc fromJson*(e: JsonNode, T: typedesc[GetCollectiblesDataResponse]): GetCollectiblesDataResponse {.inline.} =
  var collectibles: seq[CollectibleData] = @[]
  if e.hasKey("collectibles"):
    let jsonCollectibles = e["collectibles"]
    for item in jsonCollectibles.getElems():
      collectibles.add(fromJson(item, CollectibleData))

  result = T(
    collectibles: collectibles,
    errorCode: ErrorCode(e["errorCode"].getInt())
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

rpc(filterOwnedCollectiblesAsync, "wallet"):
  chainIDs: seq[int]
  addresses: seq[string]
  offset: int
  limit: int

rpc(getCollectiblesDataAsync, "wallet"):
  uniqueIds: seq[CollectibleUniqueID]
