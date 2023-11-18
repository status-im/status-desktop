import Tables, json, stint, json_serialization, strformat

import ../app_service/service/eth/dto/transaction
import ./core as core

type
  TransactionsSignatures* = Table[string, tuple[r: string, s: string, v: string]]

# mirrors the MultiTransactionType from status-go, services/wallet/transfer/transaction.go
type
  MultiTransactionType* = enum
    MultiTransactionSend = 0,
    MultiTransactionSwap = 1,
    MultiTransactionBridge = 2

  MultiTransactionCommandDto* = ref object of RootObj
    fromAddress* {.serializedFieldName("fromAddress").}: string
    toAddress* {.serializedFieldName("toAddress").}: string
    fromAsset* {.serializedFieldName("fromAsset").}: string
    toAsset* {.serializedFieldName("toAsset").}: string
    fromAmount* {.serializedFieldName("fromAmount").}: string
    multiTxType* {.serializedFieldName("type").}: MultiTransactionType

  MultiTransactionDto* = ref object of RootObj
    id* {.serializedFieldName("id").}: int
    timestamp* {.serializedFieldName("timestamp").}: int
    fromAddress* {.serializedFieldName("fromAddress").}: string
    toAddress* {.serializedFieldName("toAddress").}: string
    fromAsset* {.serializedFieldName("fromAsset").}: string
    toAsset* {.serializedFieldName("toAsset").}: string
    fromAmount* {.serializedFieldName("fromAmount").}: string
    toAmount* {.serializedFieldName("toAmount").}: string
    multiTxType* {.serializedFieldName("type").}: MultiTransactionType

# Mirrors the transfer events from status-go, services/wallet/transfer/commands.go
const EventNewTransfers*: string = "new-transfers"
const EventFetchingRecentHistory*: string = "recent-history-fetching"
const EventRecentHistoryReady*: string = "recent-history-ready"
const EventFetchingHistoryError*: string = "fetching-history-error"
const EventNonArchivalNodeDetected*: string = "non-archival-node-detected"

# Mirrors the pending transfer event from status-go, status-go/services/wallet/transfer/transaction.go
const EventPendingTransactionUpdate*: string = "pending-transaction-update"
const EventMTTransactionUpdate*: string = "multi-transaction-update"

proc `$`*(self: MultiTransactionDto): string =
  return fmt"""MultiTransactionDto(
    id:{self.id},
    timestamp:{self.timestamp},
    fromAddress:{self.fromAddress},
    toAddress:{self.toAddress},
    fromAsset:{self.fromAsset},
    toAsset:{self.toAsset},
    fromAmount:{self.fromAmount},
    toAmount:{self.toAmount},
    multiTxType:{self.multiTxType}
  )"""

proc getTransactionByHash*(chainId: int, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_getTransactionByHash", chainId, %* [hash])

proc checkRecentHistory*(chainIds: seq[int], addresses: seq[string]) {.raises: [Exception].} =
  let payload = %* [chainIds, addresses]
  discard core.callPrivateRPC("wallet_checkRecentHistoryForChainIDs", payload)

proc getTransfersByAddress*(chainId: int, address: string, toBlock: Uint256, limitAsHexWithoutLeadingZeros: string,
  loadMore: bool = false): RpcResponse[JsonNode] {.raises: [Exception].} =
  let toBlockParsed = if not loadMore: newJNull() else: %("0x" & stint.toHex(toBlock))

  core.callPrivateRPC("wallet_getTransfersByAddressAndChainID", %* [chainId, address, toBlockParsed, limitAsHexWithoutLeadingZeros, loadMore])

proc getTransactionReceipt*(chainId: int, transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_getTransactionReceipt", chainId, %* [transactionHash])

proc fetchCryptoServices*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = core.callPrivateRPC("wallet_getCryptoOnRamps", %* [])

proc createMultiTransaction*(multiTransactionCommand: MultiTransactionCommandDto, data: seq[TransactionBridgeDto], password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [multiTransactionCommand, data, password]
  result = core.callPrivateRPC("wallet_createMultiTransaction", payload)

proc proceedWithTransactionsSignatures*(signatures: TransactionsSignatures): RpcResponse[JsonNode] {.raises: [Exception].} =
  var data = %* {}
  for key, value in signatures:
    data[key] = %* { "r": value.r, "s": value.s, "v": value.v }

  var payload = %* [data]
  result = core.callPrivateRPC("wallet_proceedWithTransactionsSignatures", payload)

proc getMultiTransactions*(transactionIDs: seq[int]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [transactionIDs]
  result = core.callPrivateRPC("wallet_getMultiTransactions", payload)

proc watchTransaction*(chainId: int, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, hash]
  core.callPrivateRPC("wallet_watchTransactionByChainID", payload)
