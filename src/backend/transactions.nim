import json, stint, chronicles

import ./core as core

proc checkRecentHistory*(addresses: seq[string]) {.raises: [Exception].} =
  let payload = %* [addresses]
  discard callPrivateRPC("wallet_checkRecentHistory", payload)

proc getTransfersByAddress*(address: string, toBlock: Uint256, limitAsHexWithoutLeadingZeros: string,
  loadMore: bool = false): RpcResponse[JsonNode] {.raises: [Exception].} =
  let toBlockParsed = if not loadMore: newJNull() else: %("0x" & stint.toHex(toBlock))

  callPrivateRPC("wallet_getTransfersByAddress", %* [address, toBlockParsed, limitAsHexWithoutLeadingZeros, loadMore])

proc trackPendingTransaction*(hash: string, fromAddress: string, toAddress: string, trxType: string, data: string):
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
    "gasLimit": 0
  }]
  callPrivateRPC("wallet_storePendingTransaction", payload)

proc getTransactionReceipt*(transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =    
  callPrivateRPC("eth_getTransactionReceipt", %* [transactionHash])
  
proc deletePendingTransaction*(transactionHash: string): RpcResponse[JsonNode] {.raises: [Exception].} =    
  let payload = %* [transactionHash]
  result = callPrivateRPC("wallet_deletePendingTransaction", payload)
  
proc getPendingOutboundTransactionsByAddress*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =    
  let payload = %* [address]
  result = callPrivateRPC("wallet_getPendingOutboundTransactionsByAddress", payload)

proc fetchCryptoServices*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = core.callPrivateRPC("wallet_getCryptoOnRamps", %* [])
  
