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

type AccountDto* = object
  name*: string 
  timestamp*: int64
  identicon*: string
  keycardPairing*: string
  keyUid*: string
  images*: seq[Image]

proc isValid*(self: AccountDto): bool =
  result = self.name.len > 0 and self.keyUid.len > 0

proc toImage(jsonObj: JsonNode): Image =
  result = Image()
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("type", result.imgType)
  discard jsonObj.getProp("uri", result.uri)
  discard jsonObj.getProp("width", result.width)
  discard jsonObj.getProp("height", result.height)
  discard jsonObj.getProp("fileSize", result.fileSize)
  discard jsonObj.getProp("resizeTarget", result.resizeTarget)

proc toAccountDto*(jsonObj: JsonNode): AccountDto =
  result = AccountDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("timestamp", result.timestamp)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("keycard-pairing", result.keycardPairing)
  discard jsonObj.getProp("key-uid", result.keyUid)
  
  var imagesObj: JsonNode
  if(jsonObj.getProp("images", imagesObj)):
    result.images.add(toImage(imagesObj))