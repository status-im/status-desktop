import json
import core
import response_type

export response_type

proc getDappPermissions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("permissions_getDappPermissions", payload)

proc addDappPermissions*(dapp: string, address: string, permissions: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[{
    "dapp": dapp,
    "address": address,
    "permissions": permissions
  }]
  result = callPrivateRPC("permissions_addDappPermissions", payload)

proc deleteDappPermissions*(dapp: string, address: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [dapp, address]
  result = callPrivateRPC("permissions_deleteDappPermissionsByNameAndAddress", payload)
