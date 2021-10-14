import json

include ../../../common/json_utils

type BookmarkDto* = object
    name*: string
    url*: string
    imageUrl*: string

proc toBookmarkDto*(jsonObj: JsonNode): BookmarkDto =
  result = BookmarkDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("imageUrl", result.imageUrl)
