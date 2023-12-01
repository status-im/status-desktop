import times, strformat, options, logging
import json, json_serialization
import core, response_type
import stint

import web3/ethtypes as eth
import web3/conversions

import app_service/common/types
from gen import rpc
import backend

export response_type

# see status-go/services/wallet/activity/filter.go NoLimitTimestampForPeriod
const noLimitTimestampForPeriod* = 0

# Declared in services/wallet/activity/service.go
const eventActivityFilteringDone*: string = "wallet-activity-filtering-done"
const eventActivityFilteringUpdate*: string = "wallet-activity-filtering-entries-updated"
const eventActivityGetRecipientsDone*: string = "wallet-activity-get-recipients-result"
const eventActivityGetOldestTimestampDone*: string = "wallet-activity-get-oldest-timestamp-result"
const eventActivityFetchTransactionDetails*: string = "wallet-activity-fetch-transaction-details-result"
const eventActivityGetCollectiblesDone*: string = "wallet-activity-get-collectibles"

type
  Period* = object
    startTimestamp*: int
    endTimestamp*: int

  # see status-go/services/wallet/activity/filter.go Type
  ActivityType* {.pure.} = enum
    Send, Receive, Buy, Swap, Bridge, ContractDeployment, Mint

  # see status-go/services/wallet/activity/filter.go Status
  ActivityStatus* {.pure.} = enum
    Failed, Pending, Complete, Finalized

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

proc `$`*(tt: TokenType): string {.inline.} =
  case tt:
    of TokenType.Native:
      return "ETH"
    of TokenType.ERC20:
      return "ERC-20"
    of TokenType.ERC721:
      return "ERC-721"
    of TokenType.ERC1155:
      return "ERC-1155"
    of TokenType.Unknown:
      return "Unknown"
    of TokenType.ENS:
      return "ENS"

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

proc `==`*(c1, c2: ChainId): bool =
    return int(c1) == int(c2)

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

proc `%`*(pt: PayloadType): JsonNode {.inline.} =
  return newJInt(ord(pt))

proc fromJson*(jn: JsonNode, T: typedesc[PayloadType]): PayloadType {.inline.} =
  return cast[PayloadType](jn.getInt())

# Mirrors status-go/services/wallet/activity/activity.go ProtocolType
type
  ProtocolType* {.pure} = enum
    Hop = 1
    Uniswap

# Define toJson proc for ProtocolType
proc `%`*(pt: ProtocolType): JsonNode {.inline.} =
  return newJInt(ord(pt))

# Define fromJson proc for ProtocolType
proc fromJson*(jn: JsonNode, T: typedesc[ProtocolType]): ProtocolType {.inline.} =
  return cast[ProtocolType](jn.getInt())

proc `$`*(pt: ProtocolType): string {.inline.} =
  case pt:
    of Hop:
      return "Hop"
    of Uniswap:
      return "Uniswap"
    else:
      return ""

# Mirrors status-go/services/wallet/activity/activity.go TransferType
type
  TransferType* {.pure.} = enum
    Eth = 1
    Erc20
    Erc721
    Erc1155

proc `%`*(pt: TransferType): JsonNode {.inline.} =
  return newJInt(ord(pt))

proc fromJson*(jn: JsonNode, T: typedesc[TransferType]): TransferType {.inline.} =
  return cast[TransferType](jn.getInt())

# Mirrors status-go/services/wallet/activity/activity.go Entry
type
  ActivityEntry* = object
    # Identification
    payloadType: PayloadType
    transaction: Option[TransactionIdentity]
    id: int

    timestamp*: int

    activityType*: ActivityType
    activityStatus*: ActivityStatus

    amountOut*: UInt256
    amountIn*: UInt256

    tokenOut*: Option[Token]
    tokenIn*: Option[Token]
    symbolOut*: Option[string]
    symbolIn*: Option[string]

    sender*: Option[eth.Address]
    recipient*: Option[eth.Address]
    chainIdOut*: Option[ChainId]
    chainIdIn*: Option[ChainId]
    transferType*: Option[TransferType]

  # Mirrors status-go/services/wallet/activity/activity.go EntryData
  Data* = object
    payloadType*: PayloadType
    transaction*: Option[TransactionIdentity]
    id*: Option[int]

    timestamp*: Option[int]

    activityType*: Option[ActivityType]
    activityStatus*: Option[ActivityStatus]

    amountOut*: Option[UInt256]
    amountIn*: Option[UInt256]

    tokenOut*: Option[Token]
    tokenIn*: Option[Token]
    symbolOut*: Option[string]
    symbolIn*: Option[string]

    sender*: Option[eth.Address]
    recipient*: Option[eth.Address]
    chainIdOut*: Option[ChainId]
    chainIdIn*: Option[ChainId]
    transferType*: Option[TransferType]

    nftName*: Option[string]
    nftUrl*: Option[string]

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

proc getPayloadType*(ae: ActivityEntry): PayloadType =
  return ae.payloadType

proc getTransactionIdentity*(ae: ActivityEntry): Option[TransactionIdentity] =
  if ae.payloadType == PayloadType.MultiTransaction:
    return none(TransactionIdentity)
  return ae.transaction

proc getMultiTransactionId*(ae: ActivityEntry): Option[int] =
  if ae.payloadType != PayloadType.MultiTransaction:
    return none(int)
  return some(ae.id)

proc toJson*(ae: ActivityEntry): JsonNode {.inline.} =
  return %*(ae)

proc fromJson*(e: JsonNode, T: typedesc[Data]): Data {.inline.} =
  const transactionField = "transaction"
  const idField = "id"
  const activityTypeField = "activityType"
  const activityStatusField = "activityStatus"
  const timestampField = "timestamp"
  const amountOutField = "amountOut"
  const amountInField = "amountIn"
  const tokenOutField = "tokenOut"
  const tokenInField = "tokenIn"
  const symbolOutField = "symbolOut"
  const symbolInField = "symbolIn"
  const senderField = "sender"
  const recipientField = "recipient"
  const chainIdOutField = "chainIdOut"
  const chainIdInField = "chainIdIn"
  const transferTypeField = "transferType"
  const nftNameField = "nftName"
  const nftUrlField = "nftUrl"
  result = T(
    payloadType: fromJson(e["payloadType"], PayloadType),
    transaction:  if e.hasKey(transactionField):
                    fromJson(e[transactionField], Option[TransactionIdentity])
                  else:
                    none(TransactionIdentity),
    id: if e.hasKey(idField): some(e[idField].getInt()) else: none(int),
    activityType: if e.hasKey(activityTypeField):
                    some(fromJson(e[activityTypeField], ActivityType))
                  else:
                    none(ActivityType),
    activityStatus: if e.hasKey(activityStatusField):
                      some(fromJson(e[activityStatusField], ActivityStatus))
                    else:
                      none(ActivityStatus),
    timestamp: if e.hasKey(timestampField): some(e[timestampField].getInt()) else: none(int),
    amountOut: if e.hasKey(amountOutField): some(stint.fromHex(UInt256, e[amountOutField].getStr())) else: none(UInt256),
    amountIn: if e.hasKey(amountInField): some(stint.fromHex(UInt256, e[amountInField].getStr())) else: none(UInt256),
    tokenOut: if e.contains(tokenOutField):
                some(fromJson(e[tokenOutField], Token))
              else:
                none(Token),
    tokenIn:  if e.contains(tokenInField):
                some(fromJson(e[tokenInField], Token))
              else:
                none(Token),
    symbolOut:  if e.contains(symbolOutField):
                  some(e[symbolOutField].getStr())
                else:
                  none(string),
    symbolIn: if e.contains(symbolInField):
                some(e[symbolInField].getStr())
              else:
                none(string),

    nftName: if e.contains(nftNameField): some(e[nftNameField].getStr()) else: none(string),
    nftUrl: if e.contains(nftUrlField): some(e[nftUrlField].getStr()) else: none(string),
  )
  if e.hasKey(senderField) and e[senderField].kind != JNull:
    var address: eth.Address
    fromJson(e[senderField], senderField, address)
    result.sender = some(address)
  if e.hasKey(recipientField) and e[recipientField].kind != JNull:
    var address: eth.Address
    fromJson(e[recipientField], recipientField, address)
    result.recipient = some(address)
  if e.hasKey(chainIdOutField) and e[chainIdOutField].kind != JNull:
    result.chainIdOut = some(fromJson(e[chainIdOutField], ChainId))
  if e.hasKey(chainIdInField) and e[chainIdInField].kind != JNull:
    result.chainIdIn = some(fromJson(e[chainIdInField], ChainId))
  if e.hasKey(transferTypeField) and e[transferTypeField].kind != JNull:
    result.transferType = some(fromJson(e[transferTypeField], TransferType))

proc fromJson*(e: JsonNode, T: typedesc[ActivityEntry]): ActivityEntry {.inline.} =
  let data = fromJson(e, Data)
  result = T(
    payloadType: data.payloadType,
    transaction: data.transaction,
    id: if data.id.isSome: data.id.get() else: 0,
    activityType: data.activityType.get(),
    activityStatus: data.activityStatus.get(),
    timestamp: data.timestamp.get(),
    amountOut: data.amountOut.get(),
    amountIn: data.amountIn.get(),
    tokenOut: data.tokenOut,
    tokenIn: data.tokenIn,
    symbolOut: data.symbolOut,
    symbolIn: data.symbolIn,
    sender: data.sender,
    recipient: data.recipient,
    chainIdOut: data.chainIdOut,
    chainIdIn: data.chainIdIn,
    transferType: data.transferType,
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
    symbolOut* {$self.symbolOut}
    symbolIn* {$self.symbolIn}
    sender* {$self.sender}
    recipient* {$self.recipient}
    chainIdOut* {$self.chainIdOut}
    chainIdIn* {$self.chainIdIn}
    transferType* {$self.transferType}
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
  requestId: int32
  addresses: seq[string]
  allAddresses: bool
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
  requestId: int32
  chainIDs: seq[int]
  addresses: seq[string]
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
  requestId: int32
  addresses: seq[string]

type 
  # Mirrors services/wallet/thirdparty/collectible_types.go ContractID
  ContractID* = ref object of RootObj
    chainID*: int
    address*: string

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleUniqueID
  CollectibleUniqueID* = ref object of RootObj
    contractID*: ContractID
    tokenID*: UInt256

  # see services/wallet/activity/service.go CollectibleHeader
  CollectibleHeader* = object
    id* : CollectibleUniqueID
    name*: string
    imageUrl*: string

  # see services/wallet/activity/service.go CollectiblesResponse
  GetCollectiblesResponse* = object
    collectibles*: seq[CollectibleHeader]
    offset*: int
    hasMore*: bool
    errorCode*: ErrorCode

proc fromJson*(t: JsonNode, T: typedesc[ContractID]): ContractID {.inline.} =
  result = ContractID()
  result.chainID = t["chainID"].getInt()
  result.address = t["address"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[CollectibleUniqueID]): CollectibleUniqueID {.inline.} =
  result = CollectibleUniqueID()
  result.contractID = fromJson(t["contractID"], ContractID)
  result.tokenID = stint.parse(t["tokenID"].getStr(), UInt256)

proc fromJson*(t: JsonNode, T: typedesc[CollectibleHeader]): CollectibleHeader {.inline.} =
  result = CollectibleHeader()
  result.id = fromJson(t["id"], CollectibleUniqueID)
  result.name = t["name"].getStr()
  result.imageUrl = t["image_url"].getStr()

proc fromJson*(e: JsonNode, T: typedesc[GetCollectiblesResponse]): GetCollectiblesResponse {.inline.} =
  var collectibles: seq[CollectibleHeader] = @[]
  if e.hasKey("collectibles"):
    let jsonCollectibles = e["collectibles"]
    for item in jsonCollectibles.getElems():
      collectibles.add(fromJson(item, CollectibleHeader))

  result = T(
    collectibles: collectibles,
    hasMore: e["hasMore"].getBool(),
    offset: e["offset"].getInt(),
    errorCode: ErrorCode(e["errorCode"].getInt())
  )

rpc(getActivityCollectiblesAsync, "wallet"):
  requestId: int32
  chainIDs: seq[int]
  addresses: seq[string]
  offset: int
  limit: int

rpc(getMultiTxDetails, "wallet"):
  id: int

rpc(getTxDetails, "wallet"):
  id: string
