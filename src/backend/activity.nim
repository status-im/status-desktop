import times, strformat, options
import json, json_serialization
import core, response_type
from gen import rpc
import backend
import transactions

export response_type

# see status-go/services/wallet/activity/filter.go NoLimitTimestampForPeriod
const noLimitTimestampForPeriod = 0

# TODO: consider using common status-go types via protobuf
# TODO: consider using flags instead of list of enums
type
  Period* = object
    startTimestamp* : int
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

  # see status-go/services/wallet/activity/filter.go TokenCode, TokenAddress
  TokenCode* = distinct string
  # Not used for now until collectibles are supported in the backend. TODO: extend this with chain ID and token ID
  TokenAddress* = distinct string

  # see status-go/services/wallet/activity/filter.go Tokens
    # All empty sequences or none Options mean include all
  Tokens* = object
    assets*: Option[seq[TokenCode]]
    collectibles*: Option[seq[TokenAddress]]
    enabledTypes*: seq[TokenType]

  # see status-go/services/wallet/activity/filter.go Filter
  # All empty sequences mean include all
  ActivityFilter* = object
    period*: Period
    types*: seq[ActivityType]
    statuses*: seq[ActivityStatus]
    tokens*: Tokens
    counterpartyAddresses*: seq[string]

proc toJson[T](obj: Option[T]): JsonNode =
  if obj.isSome:
    toJson(obj.get())
  else:
    newJNull()

proc fromJson[T](jsonObj: JsonNode, TT: typedesc[Option[T]]): Option[T] =
  if jsonObj.kind != JNull:
    return some(to(jsonObj, T))
  else:
    return none(T)

proc `%`*(at: ActivityType): JsonNode {.inline.} =
  return newJInt(ord(at))

proc `%`*(aSt: ActivityStatus): JsonNode {.inline.} =
  return newJInt(ord(aSt))

proc `$`*(tc: TokenCode): string = $(string(tc))
proc `$`*(ta: TokenAddress): string = $(string(ta))

proc `%`*(tc: TokenCode): JsonNode {.inline.} =
  return %(string(tc))

proc `%`*(ta: TokenAddress): JsonNode {.inline.} =
  return %(string(ta))

proc parseJson*(tc: var TokenCode, node: JsonNode) =
  tc = TokenCode(node.getStr)

proc parseJson*(ta: var TokenAddress, node: JsonNode) =
  ta = TokenAddress(node.getStr)

proc newAllTokens(): Tokens =
  result.assets = none(seq[TokenCode])
  result.collectibles = none(seq[TokenAddress])

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
  result = ActivityFilter(period: newPeriod(none(DateTime), none(DateTime)), types: @[], statuses: @[],
                          tokens: newAllTokens(), counterpartyAddresses: @[])

# Empty sequence for paramters means include all
proc newActivityFilter*(period: Period, activityType: seq[ActivityType], activityStatus: seq[ActivityStatus],
                        tokens: Tokens, counterpartyAddress: seq[string]): ActivityFilter =
  result.period = period
  result.types = activityType
  result.statuses = activityStatus
  result.tokens = tokens
  result.counterpartyAddresses = counterpartyAddress

# Mirrors status-go/services/wallet/activity/activity.go PayloadType
type
  PayloadType* {.pure.} = enum
    MultiTransaction = 1
    SimpleTransaction
    PendingTransaction

# Define toJson proc for PayloadType
proc `%`*(x: PayloadType): JsonNode {.inline.} =
  return newJInt(ord(x))

# Define fromJson proc for PayloadType
proc fromJson*(x: JsonNode, T: typedesc[PayloadType]): PayloadType {.inline.} =
  return cast[PayloadType](x.getInt())

# TODO: hide internals behind safe interface
type
  ActivityEntry* = object
    # Identification
    payloadType*: PayloadType
    transaction*: Option[TransactionIdentity]
    id*: int

    timestamp*: int
    # TODO: change it into ActivityType
    activityType*: MultiTransactionType
    activityStatus*: ActivityStatus
    tokenType*: TokenType

# Define toJson proc for PayloadType
proc toJson*(ae: ActivityEntry): JsonNode {.inline.} =
  return %*(ae)

# Define fromJson proc for PayloadType
proc fromJson*(e: JsonNode, T: typedesc[ActivityEntry]): ActivityEntry {.inline.} =
  result = T(
    payloadType: fromJson(e["payloadType"], PayloadType),
    transaction: if e.hasKey("transaction"): fromJson(e["transaction"], Option[TransactionIdentity])
                 else: none(TransactionIdentity),
    id: e["id"].getInt(),
    timestamp: e["timestamp"].getInt()
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
    tokenType* {$self.tokenType},
  )"""

rpc(getActivityEntries, "wallet"):
  addresses: seq[string]
  chainIds: seq[int]
  filter: ActivityFilter
  offset: int
  limit: int