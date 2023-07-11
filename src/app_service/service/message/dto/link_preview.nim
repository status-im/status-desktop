import json, strformat, tables
include ../../../common/json_utils

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

  var thumbnail: JsonNode
  if jsonObj.getProp("thumbnail", thumbnail):
    result.thumbnail = toLinkPreviewThumbnail(thumbnail)

proc `$`*(self: LinkPreviewThumbnail): string =
  result = fmt"""LinkPreviewThumbnail(
    width: {self.width},
    height: {self.height},
    url: {self.url},
    dataUri: {self.dataUri}
  )"""

proc `$`*(self: LinkPreview): string =
  result = fmt"""LinkPreview(
    url: {self.url},
    hostname: {self.hostname},
    title: {self.title},
    description: {self.description},
    thumbnail: {self.thumbnail}
  )"""
