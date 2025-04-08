import json
import ./core, ./response_type

export response_type

proc getKvstoreConfigs*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("kvstore2_getKvstoreConfigs")

proc saveKvstoreConfig*(key: string, value: bool): RpcResponse[JsonNode] =
  let payload = %* [key, value]
  return core.callPrivateRPC("kvstore2_saveKvstoreConfig", payload)
