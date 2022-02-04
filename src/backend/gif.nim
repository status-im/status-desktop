import json, chronicles, core
import response_type

export response_type

logScope:
  topics = "rpc-gif"

proc setTenorAPIKey*(key: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* [key]
  result = core.callPrivateRPC("gif_setTenorAPIKey", payload)

proc fetchGifs*(path: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* [path]
  result = core.callPrivateRPC("gif_fetchGifs", payload)

proc updateRecentGifs*(recentGifs: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* [recentGifs]
  return core.callPrivateRPC("gif_updateRecentGifs", payload)

proc updateFavoriteGifs*(favoriteGifs: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* [favoriteGifs]
  return core.callPrivateRPC("gif_updateFavoriteGifs", payload)

proc getRecentGifs*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* []
  return core.callPrivateRPC("gif_getRecentGifs", payload)

proc getFavoriteGifs*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload =  %* []
  return core.callPrivateRPC("gif_getFavoriteGifs", payload)
