import Tables, json, stint, json_serialization, stew/shims/strformat, logging

import ./core as core

include common

type TransactionsSignatures* = Table[string, tuple[r: string, s: string, v: string]]

# mirrors the MultiTransactionType from status-go, services/wallet/transfer/transaction.go
type
  MultiTransactionType* = enum
    MultiTransactionSend = 0
    MultiTransactionSwap = 1
    MultiTransactionBridge = 2
    MultiTransactionApprove = 3

  MultiTransactionCommandDto* = ref object of RootObj
    fromAddress* {.serializedFieldName("fromAddress").}: string
    toAddress* {.serializedFieldName("toAddress").}: string
    fromAsset* {.serializedFieldName("fromAsset").}: string
    toAsset* {.serializedFieldName("toAsset").}: string
    fromAmount* {.serializedFieldName("fromAmount").}: string
    toAmount* {.serializedFieldName("toAmount").}: string
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
const EventFetchingRecentHistory*: string = "recent-history-fetching"
const EventRecentHistoryReady*: string = "recent-history-ready"
const EventFetchingHistoryError*: string = "fetching-history-error"
const EventNonArchivalNodeDetected*: string = "non-archival-node-detected"

# Mirrors the pending transfer event from status-go, status-go/services/wallet/transfer/transaction.go
const EventPendingTransactionUpdate*: string = "pending-transaction-update"

proc `$`*(self: MultiTransactionDto): string =
  return
    fmt"""MultiTransactionDto(
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

proc `%`*(self: MultiTransactionCommandDto): JsonNode {.inline.} =
  result = newJObject()
  result["fromAddress"] = %(self.fromAddress)
  result["toAddress"] = %(self.toAddress)
  result["fromAsset"] = %(self.fromAsset)
  result["toAsset"] = %(self.toAsset)
  result["fromAmount"] = %(self.fromAmount)
  result["toAmount"] = %(self.toAmount)
  result["type"] = %int(self.multiTxType)

proc getTransactionByHash*(chainId: int, hash: string): RpcResponse[JsonNode] =
  core.callPrivateRPCWithChainId("eth_getTransactionByHash", chainId, %*[hash])

proc checkRecentHistory*(chainIds: seq[int], addresses: seq[string]) =
  let payload = %*[chainIds, addresses]
  discard core.callPrivateRPC("wallet_checkRecentHistoryForChainIDs", payload)

proc getTransfersByAddress*(
    chainId: int,
    address: string,
    toBlock: Uint256,
    limitAsHexWithoutLeadingZeros: string,
    loadMore: bool = false,
): RpcResponse[JsonNode] =
  let toBlockParsed =
    if not loadMore:
      newJNull()
    else:
      %("0x" & stint.toHex(toBlock))

  core.callPrivateRPC(
    "wallet_getTransfersByAddressAndChainID",
    %*[chainId, address, toBlockParsed, limitAsHexWithoutLeadingZeros, loadMore],
  )

proc getTransactionReceipt*(
    chainId: int, transactionHash: string
): RpcResponse[JsonNode] =
  core.callPrivateRPCWithChainId(
    "eth_getTransactionReceipt", chainId, %*[transactionHash]
  )

proc getMultiTransactions*(transactionIDs: seq[int]): RpcResponse[JsonNode] =
  let payload = %*[transactionIDs]
  result = core.callPrivateRPC("wallet_getMultiTransactions", payload)

proc watchTransaction*(chainId: int, hash: string): RpcResponse[JsonNode] =
  let payload = %*[chainId, hash]
  core.callPrivateRPC("wallet_watchTransactionByChainID", payload)

proc buildTransactionsFromRoute*(
    resultOut: var JsonNode, uuid: string, slippagePercentage: float
): string =
  try:
    let payload = %*[{"uuid": uuid, "slippagePercentage": slippagePercentage}]
    let response = core.callPrivateRPC("wallet_buildTransactionsFromRoute", payload)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg

proc sendRouterTransactionsWithSignatures*(
    resultOut: var JsonNode, uuid: string, signatures: TransactionsSignatures
): string =
  try:
    var jsonSignatures = %*{}
    for key, value in signatures:
      jsonSignatures[key] = %*{"r": value.r, "s": value.s, "v": value.v}

    var payload = %*[{"uuid": uuid, "signatures": jsonSignatures}]
    let response =
      core.callPrivateRPC("wallet_sendRouterTransactionsWithSignatures", payload)
    return prepareResponse(resultOut, response)
  except Exception as e:
    warn e.msg
    return e.msg
