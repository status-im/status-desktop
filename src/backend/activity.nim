import times, strformat
import json, json_serialization
import options
import ./core, ./response_type
from ./gen import rpc
import ./backend
import transactions

export response_type

# TODO: consider using common status-go types via protobuf
# TODO: consider using flags instead of list of enums
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
    Asset, Collectibles

  # see status-go/services/wallet/activity/filter.go Filter
  ActivityFilter* = object
    period* {.serializedFieldName("period").}: Period
    types* {.serializedFieldName("types").}: seq[ActivityType]
    statuses* {.serializedFieldName("statuses").}: seq[ActivityStatus]
    tokenTypes* {.serializedFieldName("tokenTypes").}: seq[TokenType]
    counterpartyAddresses* {.serializedFieldName("counterpartyAddresses").}: seq[string]

proc newPeriod*(startTime: Option[DateTime], endTime: Option[DateTime]): Period =
  if startTime.isSome:
    result.startTimestamp = startTime.get().toTime().toUnix().int
  else:
    result.startTimestamp = 0
  if endTime.isSome:
    result.endTimestamp = endTime.get().toTime().toUnix().int
  else:
    result.endTimestamp = 0

proc newPeriod*(startTimestamp: int, endTimestamp: int): Period =
  result.startTimestamp = startTimestamp
  result.endTimestamp = endTimestamp

proc getIncludeAllActivityFilter*(): ActivityFilter =
  result = ActivityFilter(period: newPeriod(none(DateTime), none(DateTime)), types: @[], statuses: @[], tokenTypes: @[], counterpartyAddresses: @[])

# Empty sequence for paramters means include all
proc newActivityFilter*(period: Period, activityType: seq[ActivityType], activityStatus: seq[ActivityStatus], tokenType: seq[TokenType], counterpartyAddress: seq[string]): ActivityFilter =
  result.period = period
  result.types = activityType
  result.statuses = activityStatus
  result.tokenTypes = tokenType
  result.counterpartyAddresses = counterpartyAddress

# Mirrors status-go/services/wallet/activity/activity.go PayloadType
type
  PayloadType* {.pure.} = enum
    MultiTransaction = 1
    SimpleTransaction
    PendingTransaction

# Define toJson proc for PayloadType
proc toJson*(x: PayloadType): JsonNode {.inline.} =
  return %*(ord(x))

# Define fromJson proc for PayloadType
proc fromJson*(x: JsonNode, T: typedesc[PayloadType]): PayloadType {.inline.} =
  return cast[PayloadType](x.getInt())

# TODO: hide internals behind safe interface
type
  ActivityEntry* = object
    transactionType* {.serializedFieldName("transactionType").}: PayloadType
    transaction* {.serializedFieldName("transaction").}: Option[TransactionIdentity]
    id* {.serializedFieldName("id").}: int
    timestamp* {.serializedFieldName("timestamp").}: int
    activityType* {.serializedFieldName("activityType").}: MultiTransactionType

proc fromJson[T](jsonObj: JsonNode, TT: typedesc[Option[T]]): Option[T] =
  if jsonObj.kind != JNull:
    return some(to(jsonObj, T))
  else:
    return none(T)

proc toJson[T](obj: Option[T]): JsonNode =
  if obj.isSome:
    toJson(obj.get())
  else:
    newJNull()

# Define toJson proc for PayloadType
proc toJson*(ae: ActivityEntry): JsonNode {.inline.} =
  return %*(ae)

# Define fromJson proc for PayloadType
proc fromJson*(e: JsonNode, T: typedesc[ActivityEntry]): ActivityEntry {.inline.} =
  result = T(
    transactionType: fromJson(e["transactionType"], PayloadType),
    transaction: if e.hasKey("transaction"): fromJson(e["transaction"], Option[TransactionIdentity]) else: none(TransactionIdentity),
    id: e["id"].getInt(),
    timestamp: e["timestamp"].getInt()
  )

proc `$`*(self: ActivityEntry): string =
  let transactionStr = if self.transaction.isSome: $self.transaction.get() else: "none(TransactionIdentity)"
  return fmt"""ActivityEntry(
    transactionType:{self.transactionType.int},
    transaction:{transactionStr},
    id:{self.id},
    timestamp:{self.timestamp},
  )"""

rpc(getActivityEntries, "wallet"):
  addresses: seq[string]
  chainIds: seq[int]
  filter: ActivityFilter
  offset: int
  limit: int