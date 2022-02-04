import json
import core
import response_type

export response_type

proc getDappPermissions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("permissions_getDappPermissions", payload)

proc addDappPermissions*(dapp: string, permissions: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "dapp": dapp,
    "permissions": permissions
  }]
  result = callPrivateRPC("permissions_addDappPermissions", payload)

proc deleteDappPermissions*(dapp: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [dapp]
  result = callPrivateRPC("permissions_deleteDappPermissions", payload)
