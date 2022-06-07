import json
import core, utils
import response_type
import ./backend

export response_type


proc addBookmark*(bookmark: backend.Bookmark): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("addBookmark".prefix, %*[{
    "url": bookmark.url,
    "name": bookmark.name,
    "imageUrl": bookmark.imageUrl,
    "removed": bookmark.removed,
    "deletedAt": bookmark.deletedAt
  }])

proc removeBookmark*(url: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("removeBookmark".prefix, %*[url])

proc updateBookmark*(oldUrl: string, bookmark: backend.Bookmark): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = callPrivateRPC("updateBookmark".prefix, %*[oldUrl, {
    "url": bookmark.url,
    "name": bookmark.name,
    "imageUrl": bookmark.imageUrl,
    "removed": bookmark.removed,
    "deletedAt": bookmark.deletedAt
  }])
