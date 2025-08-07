import json
import core, ../app_service/common/utils
import response_type
import ./backend

export response_type


proc addBookmark*(bookmark: backend.Bookmark): RpcResponse[JsonNode] =
  result = callPrivateRPC("addBookmark".prefix, %*[{
    "url": bookmark.url,
    "name": bookmark.name,
    "imageUrl": bookmark.imageUrl,
    "removed": bookmark.removed,
    "deletedAt": bookmark.deletedAt
  }])

proc removeBookmark*(url: string): RpcResponse[JsonNode] =
  result = callPrivateRPC("removeBookmark".prefix, %*[url])

proc updateBookmark*(oldUrl: string, bookmark: backend.Bookmark): RpcResponse[JsonNode] =
  result = callPrivateRPC("updateBookmark".prefix, %*[oldUrl, {
    "url": bookmark.url,
    "name": bookmark.name,
    "imageUrl": bookmark.imageUrl,
    "removed": bookmark.removed,
    "deletedAt": bookmark.deletedAt
  }])
