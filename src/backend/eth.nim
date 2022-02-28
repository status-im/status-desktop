import json
import ./core, ./response_type

export response_type

proc getAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("eth_accounts")

proc getBlockByNumber*(blockNumber: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [blockNumber, false]
  return core.callPrivateRPC("eth_getBlockByNumber", payload)

proc getNativeChainBalance*(chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address, "latest"]
  return core.callPrivateRPCWithChainId("eth_getBalance", chainId, payload)

proc sendTransaction*(transactionData: string, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.sendTransaction(transactionData, password)

# This is the replacement of the `call` function
proc doEthCall*(payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("eth_call", payload)

proc estimateGas*(payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("eth_estimateGas", payload)

proc getEthAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("eth_accounts")

proc getGasPrice*(payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("eth_gasPrice", payload)

proc maxPriorityFeePerGas*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("eth_maxPriorityFeePerGas", payload)

proc feeHistory*(n: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [n, "latest", nil]
  return core.callPrivateRPC("eth_feeHistory", payload)