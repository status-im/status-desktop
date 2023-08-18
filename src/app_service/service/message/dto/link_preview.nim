import json, strformat, tables
include ../../../common/json_utils

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
  LinkPreviewThumbnail* = object
    width*: int
    height*: int
    url*: string
    dataUri*: string

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

proc toLinkPreviewThumbnail*(jsonObj: JsonNode): LinkPreviewThumbnail =
  result = LinkPreviewThumbnail()
  discard jsonObj.getProp("width", result.width)
  discard jsonObj.getProp("height", result.height)
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("dataUri", result.dataUri)

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

proc `$`*(self: LinkPreviewThumbnail): string =
  result = fmt"""LinkPreviewThumbnail(
    width: {self.width},
    height: {self.height},
    urlLength: {self.url.len},
    dataUriLength: {self.dataUri.len}
  )"""

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
