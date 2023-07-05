import times, strformat, options, logging
import json, json_serialization
import core, response_type
import stint

import web3/ethtypes as eth
import web3/conversions

from gen import rpc
import backend

export response_type

# see status-go/services/wallet/activity/filter.go NoLimitTimestampForPeriod
const noLimitTimestampForPeriod = 0

# Declared in services/wallet/activity/service.go
const eventActivityFilteringDone*: string = "wallet-activity-filtering-done"
const eventActivityGetRecipientsDone*: string = "wallet-activity-get-recipients-result"
const eventActivityGetOldestTimestampDone*: string = "wallet-activity-get-oldest-timestamp-result"

type
  Period* = object
    startTimestamp*: int
    endTimestamp*: int

  # see status-go/services/wallet/activity/filter.go Type
  ActivityType* {.pure.} = enum
    Send, Receive, Buy, Swap, Bridge

  # see status-go/services/wallet/activity/filter.go Status
  ActivityStatus* {.pure.} = enum
    Failed, Pending, Complete, Finalized

  # see status-go/services/wallet/activity/filter.go TokenType
  TokenType* {.pure.} = enum
    Native, Erc20, Erc721, Erc1155

  # see status-go/services/wallet/activity/filter.go TokenID
  TokenId* = distinct string

  ChainId* = distinct int

  # see status-go/services/wallet/activity/filter.go Token
  Token* = object
    tokenType*: TokenType
    chainId*: ChainId
    address*: Option[eth.Address]
    tokenId*: Option[TokenId]

  # see status-go/services/wallet/activity/filter.go Filter
  # All empty sequences mean include all
  ActivityFilter* = object
    period*: Period
    types*: seq[ActivityType]
    statuses*: seq[ActivityStatus]
    counterpartyAddresses*: seq[string]

    # Tokens
    assets*: seq[Token]
    collectibles*: seq[Token]
    filterOutAssets*: bool
    filterOutCollectibles*: bool

proc toJson[T](obj: Option[T]): JsonNode =
  if obj.isSome:
    toJson(obj.get())
  else:
    newJNull()

proc fromJson[T](jsonObj: JsonNode, TT: typedesc[Option[T]]): Option[T] =
  if jsonObj != nil and jsonObj.kind != JNull:
    return some(to(jsonObj, T))
  else:
    return none(T)

proc `%`*(at: ActivityType): JsonNode {.inline.} =
  return newJInt(ord(at))

proc fromJson*(jn: JsonNode, T: typedesc[ActivityType]): ActivityType {.inline.} =
  return cast[ActivityType](jn.getInt())

proc `%`*(aSt: ActivityStatus): JsonNode {.inline.} =
  return newJInt(ord(aSt))

proc fromJson*(jn: JsonNode, T: typedesc[ActivityStatus]): ActivityStatus {.inline.} =
  return cast[ActivityStatus](jn.getInt())

proc `%`*(tt: TokenType): JsonNode {.inline.} =
  return newJInt(ord(tt))

proc fromJson*(jn: JsonNode, T: typedesc[TokenType]): TokenType {.inline.} =
  return cast[TokenType](jn.getInt())

proc `$`*(tc: TokenId): string = $(string(tc))

proc `%`*(tc: TokenId): JsonNode {.inline.} =
  return %(string(tc))

proc fromJson*(jn: JsonNode, T: typedesc[TokenId]): TokenId {.inline.} =
  return cast[TokenId](jn.getStr())

proc `%`*(cid: ChainId): JsonNode {.inline.} =
  return %(int(cid))

proc fromJson*(jn: JsonNode, T: typedesc[ChainId]): ChainId {.inline.} =
  return cast[ChainId](jn.getInt())

proc `$`*(cid: ChainId): string = $(int(cid))

const addressField = "address"
const tokenIdField = "tokenId"

proc `%`*(t: Token): JsonNode {.inline.} =
  result = newJObject()
  result["tokenType"] = %(t.tokenType)
  result["chainId"] = %(t.chainId)

  if t.address.isSome:
    result[addressField] = %(t.address.get)

  if t.tokenId.isSome:
    result[tokenIdField] = %(t.tokenId.get)

proc `%`*(t: ref Token): JsonNode {.inline.} =
  return %(t[])

proc fromJson*(t: JsonNode, T: typedesc[Token]): Token {.inline.} =
  result = Token()
  result.tokenType = fromJson(t["tokenType"], TokenType)
  result.chainId = fromJson(t["chainId"], ChainId)

  if t.contains(addressField) and t[addressField].kind != JNull:
    var address: eth.Address
    fromJson(t[addressField], addressField, address)
    result.address = some(address)

  if t.contains(tokenIdField) and t[tokenIdField].kind != JNull:
    result.tokenId = fromJson(t[tokenIdField], Option[TokenId])

proc fromJson*(t: JsonNode, T: typedesc[ref Token]): ref Token {.inline.} =
  result = new(Token)
  result[] = fromJson(t, Token)

proc `$`*(t: Token): string =
  return fmt"""Token(
    tokenType: {t.tokenType},
    chainId*: {t.chainId},
    address*: {t.address},
    tokenId*: {t.tokenId}
  )"""

proc `$`*(t: ref Token): string =
  return $(t[])

proc newAllTokens(): seq[Token] =
  return @[]

proc newPeriod*(startTime: Option[DateTime], endTime: Option[DateTime]): Period =
  if startTime.isSome:
    result.startTimestamp = startTime.get().toTime().toUnix().int
  else:
    result.startTimestamp = noLimitTimestampForPeriod
  if endTime.isSome:
    result.endTimestamp = endTime.get().toTime().toUnix().int
  else:
    result.endTimestamp = noLimitTimestampForPeriod

proc newPeriod*(startTimestamp: int, endTimestamp: int): Period =
  result.startTimestamp = startTimestamp
  result.endTimestamp = endTimestamp

proc getIncludeAllActivityFilter*(): ActivityFilter =
  result = ActivityFilter(period: newPeriod(none(DateTime), none(DateTime)),
                          types: @[], statuses: @[], counterpartyAddresses: @[],
                          assets: newAllTokens(), collectibles: newAllTokens(),
                          filterOutAssets: false, filterOutCollectibles: false)

# Empty sequence for paramters means include all
proc newActivityFilter*(period: Period, activityType: seq[ActivityType], activityStatus: seq[ActivityStatus],
                        counterpartyAddress: seq[string],
                        assets: seq[Token], collectibles: seq[Token],
                        filterOutAssets: bool, filterOutCollectibles: bool): ActivityFilter =
  result.period = period
  result.types = activityType
  result.statuses = activityStatus
  result.counterpartyAddresses = counterpartyAddress
  result.assets = assets
  result.collectibles = collectibles
  result.filterOutAssets = filterOutAssets
  result.filterOutCollectibles = filterOutCollectibles

# Mirrors status-go/services/wallet/activity/activity.go PayloadType
type
  PayloadType* {.pure.} = enum
    MultiTransaction = 1
    SimpleTransaction
    PendingTransaction

# Define toJson proc for PayloadType
proc `%`*(pt: PayloadType): JsonNode {.inline.} =
  return newJInt(ord(pt))

# Define fromJson proc for PayloadType
proc fromJson*(jn: JsonNode, T: typedesc[PayloadType]): PayloadType {.inline.} =
  return cast[PayloadType](jn.getInt())

# TODO: hide internals behind safe interface
type
  ActivityEntry* = object
    # Identification
    payloadType*: PayloadType
    transaction*: Option[TransactionIdentity]
    id*: int

    timestamp*: int

    activityType*: ActivityType
    activityStatus*: ActivityStatus

    amountOut*: UInt256
    amountIn*: UInt256

    tokenOut*: Option[Token]
    tokenIn*: Option[Token]

  # Mirrors services/wallet/activity/service.go ErrorCode
  ErrorCode* = enum
    ErrorCodeSuccess = 1,
    ErrorCodeTaskCanceled,
    ErrorCodeFailed

  # Mirrors services/wallet/activity/service.go FilterResponse
  FilterResponse* = object
    activities*: seq[ActivityEntry]
    offset*: int
    hasMore*: bool
    errorCode*: ErrorCode

# Define toJson proc for PayloadType
proc toJson*(ae: ActivityEntry): JsonNode {.inline.} =
  return %*(ae)

# Define fromJson proc for PayloadType
proc fromJson*(e: JsonNode, T: typedesc[ActivityEntry]): ActivityEntry {.inline.} =
  const tokenOutField = "tokenOut"
  const tokenInField = "tokenIn"
  result = T(
    payloadType: fromJson(e["payloadType"], PayloadType),
    transaction:  if e.hasKey("transaction"):
                    fromJson(e["transaction"], Option[TransactionIdentity])
                  else:
                    none(TransactionIdentity),
    id: e["id"].getInt(),
    activityType: fromJson(e["activityType"], ActivityType),
    activityStatus: fromJson(e["activityStatus"], ActivityStatus),
    timestamp: e["timestamp"].getInt(),

    amountOut: stint.fromHex(UInt256, e["amountOut"].getStr()),
    amountIn: stint.fromHex(UInt256, e["amountIn"].getStr()),

    tokenOut: if e.contains(tokenOutField):
                some(fromJson(e[tokenOutField], Token))
              else:
                none(Token),
    tokenIn:  if e.contains(tokenInField):
                some(fromJson(e[tokenInField], Token))
              else:
                none(Token)
  )

proc `$`*(self: ActivityEntry): string =
  let transactionStr = if self.transaction.isSome: $self.transaction.get()
                       else: "none(TransactionIdentity)"
  return fmt"""ActivityEntry(
    payloadType:{$self.payloadType},
    transaction:{transactionStr},
    id:{self.id},
    timestamp:{self.timestamp},
    activityType* {$self.activityType},
    activityStatus* {$self.activityStatus},
    amountOut* {$self.amountOut},
    amountIn* {$self.amountIn},
    tokenOut* {$self.tokenOut},
    tokenIn* {$self.tokenIn}
  )"""

proc fromJson*(e: JsonNode, T: typedesc[FilterResponse]): FilterResponse {.inline.} =
  var backendEntities: seq[ActivityEntry]
  if e.hasKey("activities"):
    let jsonEntries = e["activities"]
    if jsonEntries.kind == JArray:
      backendEntities = newSeq[ActivityEntry](jsonEntries.len)
      for i in 0 ..< jsonEntries.len:
        backendEntities[i] = fromJson(jsonEntries[i], ActivityEntry)
    elif jsonEntries.kind != JNull:
      error "Invalid activities field in FilterResponse; kind: ", jsonEntries.kind

  result = T(
    activities: backendEntities,
    offset: e["offset"].getInt(),
    hasMore: if e.hasKey("hasMore"): e["hasMore"].getBool()
                      else: false,
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

rpc(filterActivityAsync, "wallet"):
  addresses: seq[string]
  chainIds: seq[ChainId]
  filter: ActivityFilter
  offset: int
  limit: int

# see services/wallet/activity/service.go GetRecipientsResponse
type GetRecipientsResponse* = object
  addresses*: seq[string]
  offset*: int
  hasMore*: bool
  errorCode*: ErrorCode

proc fromJson*(e: JsonNode, T: typedesc[GetRecipientsResponse]): GetRecipientsResponse {.inline.} =
  const addressesField = "addresses"

  var addresses: seq[string]
  if e.hasKey(addressesField) and e[addressesField].kind != JNull and e[addressesField].kind == JArray:
    addresses = newSeq[string](e[addressesField].len)
    for i in 0 ..< e[addressesField].len:
      addresses[i] = e[addressesField][i].getStr()

  result = T(
    addresses: addresses,
    offset: e["offset"].getInt(),
    hasMore: if e.hasKey("hasMore"): e["hasMore"].getBool() else: false,
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

rpc(getRecipientsAsync, "wallet"):
  offset: int
  limit: int

# see services/wallet/activity/service.go GetOldestTimestampResponse
type GetOldestTimestampResponse* = object
  timestamp*: int
  errorCode*: ErrorCode

proc fromJson*(e: JsonNode, T: typedesc[GetOldestTimestampResponse]): GetOldestTimestampResponse {.inline.} =
  result = T(
    timestamp: e["timestamp"].getInt(),
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

rpc(getOldestActivityTimestampAsync, "wallet"):
  addresses: seq[string]
