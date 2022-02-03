import json, strmisc
import core, utils
import response_type

export response_type

proc getBookmarks*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = callPrivateRPC("browsers_getBookmarks", payload)

proc storeBookmark*(url, name: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{"url": url, "name": name}]
  result = callPrivateRPC("browsers_storeBookmark", payload)

proc deleteBookmark*(url: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [url]
  result = callPrivateRPC("browsers_deleteBookmark", payload)

proc updateBookmark*(originalUrl, newUrl, name: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [originalUrl, {"url": newUrl, "name": name}]
  result = callPrivateRPC("browsers_updateBookmark", payload)
