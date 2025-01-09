import json, strutils
import core
import response_type

export response_type

proc getRecentGifs*(): RpcResponse[JsonNode] =
  let payload = %*[]
  result = callPrivateRPC("gif_getRecentGifs", payload)

proc getFavoriteGifs*(): RpcResponse[JsonNode] =
  let payload = %*[]
  result = callPrivateRPC("gif_getFavoriteGifs", payload)
