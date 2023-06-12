import json, stint, json_serialization

import ../app_service/service/eth/dto/transaction
import ./core as core
import ../app_service/common/utils

# mirrors the MultiTransactionType from status-go, services/wallet/transfer/transaction.go
type
  MultiTransactionType* = enum
    MultiTransactionSend = 0, MultiTransactionSwap = 1, MultiTransactionBridge = 2

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

proc getTransactionByHash*(chainId: int, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_getTransactionByHash", chainId, %* [hash])

proc checkRecentHistory*(chainIds: seq[int], addresses: seq[string]) {.raises: [Exception].} =
  let payload = %* [chainIds, addresses]
  discard core.callPrivateRPC("wallet_checkRecentHistoryForChainIDs", payload)

proc getTransfersByAddress*(chainId: int, address: string, toBlock: Uint256, limitAsHexWithoutLeadingZeros: string,
  loadMore: bool = false): RpcResponse[JsonNode] {.raises: [Exception].} =
  let toBlockParsed = if not loadMore: newJNull() else: %("0x" & stint.toHex(toBlock))

  core.callPrivateRPC("wallet_getTransfersByAddressAndChainID", %* [chainId, address, toBlockParsed, limitAsHexWithoutLeadingZeros, loadMore])

proc trackPendingTransaction*(hash: string, fromAddress: string, toAddress: string, trxType: string, data: string, chainId: int):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
    "hash": hash,
    "from": fromAddress,
    "to": toAddress,
    "type": trxType,
    "additionalData": data,
    "data": "",
    "value": 0,
    "timestamp": 0,
    "gasPrice": 0,
    "gasLimit": 0,
    "network_id": chainId
  }]
  core.callPrivateRPC("wallet_storePendingTransaction", payload)

proc getTransactionReceipt*(chainId: int, transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_getTransactionReceipt", chainId, %* [transactionHash])

proc deletePendingTransaction*(chainId: int, transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, transactionHash]
  result = core.callPrivateRPC("wallet_deletePendingTransactionByChainID", payload)

proc fetchCryptoServices*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = core.callPrivateRPC("wallet_getCryptoOnRamps", %* [])

proc createMultiTransaction*(multiTransactionCommand: MultiTransactionCommandDto, data: seq[TransactionBridgeDto], password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [multiTransactionCommand, data, hashPassword(password)]
  result = core.callPrivateRPC("wallet_createMultiTransaction", payload)

proc getMultiTransactions*(transactionIDs: seq[int]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [transactionIDs]
  result = core.callPrivateRPC("wallet_getMultiTransactions", payload)

proc watchTransaction*(chainId: int, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, hash]
  core.callPrivateRPC("wallet_watchTransactionByChainID", payload)
