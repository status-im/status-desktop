{.used.}

import json

include ../../../common/json_utils

type
  Image* = object
    keyUid*: string
    imgType*: string
    uri*: string
    width: int
    height: int
    fileSize: int
    resizeTarget: int

type ProfileDto* = object
  images*: seq[Image]

proc toImage*(jsonObj: JsonNode): Image =
  result = Image()
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("type", result.imgType)
  discard jsonObj.getProp("uri", result.uri)
  discard jsonObj.getProp("width", result.width)
  discard jsonObj.getProp("height", result.height)
  discard jsonObj.getProp("fileSize", result.fileSize)
  discard jsonObj.getProp("resizeTarget", result.resizeTarget)

proc toProfileDto*(jsonObj: JsonNode): ProfileDto =
  result = ProfileDto()

  var imagesObj: JsonNode
  if(jsonObj.getProp("images", imagesObj) and imagesObj.kind == JArray):
    for imgObj in imagesObj:
      result.images.add(toImage(imgObj))
