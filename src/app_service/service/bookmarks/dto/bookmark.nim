import json

include ../../../common/json_utils

type BookmarkDto* = object
    name*: string
    url*: string
    imageUrl*: string
    removed*: bool
    deletedAt*: int

proc toBookmarkDto*(jsonObj: JsonNode): BookmarkDto =
  result = BookmarkDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("imageUrl", result.imageUrl)
  discard jsonObj.getProp("removed", result.removed)
  discard jsonObj.getProp("deletedAt", result.deletedAt)
