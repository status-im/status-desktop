import json
import ./core, ./response_type

export response_type

proc addSavedAddress*(name, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{"name": name, "address": address}]
  return callPrivateRPC("wallet_addSavedAddress", payload)

proc deleteSavedAddress*(address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address]
  return callPrivateRPC("wallet_deleteSavedAddress", payload)

proc getSavedAddresses*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return callPrivateRPC("wallet_getSavedAddresses", payload)
