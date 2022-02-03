import json

import ./core, ./response_type

proc getNetworks*(payload: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("wallet_getEthereumChains", payload)

proc upsertNetwork*(payload: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("wallet_addEthereumChain", payload)

proc deleteNetwork*(payload: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  core.callPrivateRPC("wallet_deleteEthereumChain", payload)