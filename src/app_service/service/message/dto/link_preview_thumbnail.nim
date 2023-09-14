
type
  LinkPreviewThumbnail* = object
    width*: int
    height*: int
    url*: string
    dataUri*: string

proc toLinkPreviewThumbnail*(jsonObj: JsonNode): LinkPreviewThumbnail =
  result = LinkPreviewThumbnail()
  discard jsonObj.getProp("width", result.width)
  discard jsonObj.getProp("height", result.height)
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("dataUri", result.dataUri)

proc `$`*(self: LinkPreviewThumbnail): string =
  result = fmt"""LinkPreviewThumbnail(
    width: {self.width},
    height: {self.height},
    urlLength: {self.url.len},
    dataUriLength: {self.dataUri.len}
  )"""
