import json
import ./core, ./response_type

export response_type

proc getAccounts*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("eth_accounts")

proc getBlockByNumber*(chainId: int, blockNumber: string, fullTransactionObject = false): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [blockNumber, fullTransactionObject]
  return core.callPrivateRPCWithChainId("eth_getBlockByNumber", chainId, payload)

proc getNativeChainBalance*(chainId: int, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address, "latest"]
  return core.callPrivateRPCWithChainId("eth_getBalance", chainId, payload)

proc sendTransaction*(chainId: int, transactionData: string, password: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.sendTransaction(chainId, transactionData, password)

# This is the replacement of the `call` function
proc doEthCall*(payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("eth_call", payload)

proc estimateGas*(chainId: int, payload = %* []): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPCWithChainId("eth_estimateGas", chainId, payload)

proc suggestedFees*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("wallet_getSuggestedFees", payload)

proc suggestedRoutes*(account: string, amount: float64, token: string, disabledChainIDs: seq[uint64]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [account, amount, token, disabledChainIDs]
  return core.callPrivateRPC("wallet_getSuggestedRoutes", payload)
