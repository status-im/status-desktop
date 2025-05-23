import json
import ./core, ./response_type

export response_type

proc getStoreEntry*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("kvstore_getStoreEntry")

proc setRlnRateLimitEnabled*(value: bool): RpcResponse[JsonNode] =
  let payload = %* [value]
  result = core.callPrivateRPC("kvstore_setRlnRateLimitEnabled", payload)
