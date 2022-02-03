import json
import ./core, ./response_type

export response_type

proc getSettings*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_getSettings")

proc saveSettings*(key: string, value: string | JsonNode | bool | int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [key, value]
  result = core.callPrivateRPC("settings_saveSetting", payload)