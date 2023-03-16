import json, strutils
import core
import response_type

export response_type

proc getRecentGifs*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("gif_getRecentGifs", payload)

proc getFavoriteGifs*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("gif_getFavoriteGifs", payload)
