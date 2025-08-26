import json
import ./core, ./response_type
from ./gen import rpc

export response_type

proc getBlockByNumber*(chainId: int, blockNumber: string, fullTransactionObject = false): RpcResponse[JsonNode] =
  let payload = %* [blockNumber, fullTransactionObject]
  return core.callPrivateRPCWithChainId("eth_getBlockByNumber", chainId, payload)

proc getNativeChainBalance*(chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %* [address, "latest"]
  return core.callPrivateRPCWithChainId("eth_getBalance", chainId, payload)

# This is the replacement of the `call` function
proc doEthCall*(payload = %* []): RpcResponse[JsonNode] =
  core.callPrivateRPC("eth_call", payload)

proc estimateGas*(chainId: int, payload = %* []): RpcResponse[JsonNode] =
  core.callPrivateRPCWithChainId("eth_estimateGas", chainId, payload)

proc suggestedFees*(chainId: int): RpcResponse[JsonNode] =
  let payload = %* [chainId]
  return core.callPrivateRPC("wallet_getSuggestedFees", payload)

rpc(getEstimatedLatestBlockNumber, "wallet"):
  chainId: int
