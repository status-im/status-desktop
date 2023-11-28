import json, stint, tables
import ./core, ./response_type
from ./gen import rpc

export response_type

proc getAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("eth_accounts")

proc getBlockByNumber*(chainId: int, blockNumber: string, fullTransactionObject = false): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [blockNumber, fullTransactionObject]
  return core.callPrivateRPCWithChainId("eth_getBlockByNumber", chainId, payload)

proc getNativeChainBalance*(chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address, "latest"]
  return core.callPrivateRPCWithChainId("eth_getBalance", chainId, payload)

# This is the replacement of the `call` function
proc doEthCall*(payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("eth_call", payload)

proc estimateGas*(chainId: int, payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_estimateGas", chainId, payload)

proc suggestedFees*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("wallet_getSuggestedFees", payload)

proc suggestedRoutes*(accountFrom: string, accountTo: string, amount: string, token: string, disabledFromChainIDs,
  disabledToChainIDs, preferredChainIDs: seq[int], sendType: int, lockedInAmounts: var Table[string, string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [sendType, accountFrom, accountTo, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, 1, lockedInAmounts]
  return core.callPrivateRPC("wallet_getSuggestedRoutes", payload)

rpc(getEstimatedLatestBlockNumber, "wallet"):
  chainId: int