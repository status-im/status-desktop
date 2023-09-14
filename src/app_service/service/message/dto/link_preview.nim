import json, strformat, tables
include ../../../common/json_utils
include ./link_preview_thumbnail

type
  LinkType* {.pure.} = enum
    Link = 0
    Image

proc toLinkType*(value: int): LinkType =
  try:
    return LinkType(value)
  except RangeDefect:
    return LinkType.Link


type
  LinkPreview* = ref object
    url*: string
    hostname*: string
    title*: string
    description*: string
    thumbnail*: LinkPreviewThumbnail
    linkType*: LinkType

proc delete*(self: LinkPreview) =
  discard

proc initLinkPreview*(url: string): LinkPreview =
  result = LinkPreview()
  result.url = url


proc toLinkPreview*(jsonObj: JsonNode): LinkPreview =
  result = LinkPreview()
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("hostname", result.hostname)
  discard jsonObj.getProp("title", result.title)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("hostname", result.hostname)
  result.linkType = toLinkType(jsonObj["type"].getInt)

  var thumbnail: JsonNode
  if jsonObj.getProp("thumbnail", thumbnail):
    result.thumbnail = toLinkPreviewThumbnail(thumbnail)

proc `$`*(self: LinkPreview): string =
  result = fmt"""LinkPreview(
    type: {self.linkType},
    url: {self.url},
    hostname: {self.hostname},
    title: {self.title},
    description: {self.description},
    thumbnail: {self.thumbnail}
  )"""

# Custom JSON converter to force `linkType` integer instead of string
proc `%`*(self: LinkPreview): JsonNode =
  result = %* {
    "type": self.linkType.int,
    "url": self.url,
    "hostname": self.hostname,
    "title": self.title,
    "description": self.description,
    "thumbnail": %self.thumbnail,
  }
