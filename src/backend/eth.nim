import json
import ./core, ./response_type

export response_type

proc estimateGas*(chainId: int, transaction: JsonNode): RpcResponse[JsonNode] =
  let params = %* [chainId, transaction]
  core.callPrivateRPC("eth_estimateGas", params)

proc suggestedFees*(chainId: int): RpcResponse[JsonNode] =
  let payload = %* [chainId]
  return core.callPrivateRPC("wallet_getSuggestedFees", payload)
