{.used.}

import json
import ../../visual_identity/dto

include ../../../common/json_utils
import ../../../common/social_links

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
  keycardPairing*: string
  keyUid*: string
  images*: seq[Image]
  colorHash*: ColorHashDto
  colorId*: int
  kdfIterations*: int

type WakuBackedUpProfileDto* = object
  displayName*: string
  images*: seq[Image]
  socialLinks*: SocialLinks

proc isValid*(self: AccountDto): bool =
  result = self.name.len > 0 and self.keyUid.len > 0

proc toImage*(jsonObj: JsonNode): Image =
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
  discard jsonObj.getProp("keycard-pairing", result.keycardPairing)
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("colorId", result.colorId)
  discard jsonObj.getProp("kdfIterations", result.kdfIterations)

  if jsonObj.hasKey("colorHash"):
    result.colorHash = toColorHashDto(jsonObj["colorHash"])

  var imagesObj: JsonNode
  if(jsonObj.getProp("images", imagesObj) and imagesObj.kind == JArray):
    for imgObj in imagesObj:
      result.images.add(toImage(imgObj))

proc contains*(accounts: seq[AccountDto], keyUid: string): bool =
  for account in accounts:
    if (account.keyUid == keyUid):
      return true
  return false

proc toWakuBackedUpProfileDto*(jsonObj: JsonNode): WakuBackedUpProfileDto =
  result = WakuBackedUpProfileDto()
  discard jsonObj.getProp("displayName", result.displayName)

  var obj: JsonNode
  if(jsonObj.getProp("images", obj) and obj.kind == JArray):
    for imgObj in obj:
      result.images.add(toImage(imgObj))

  if(jsonObj.getProp("socialLinks", obj) and obj.kind == JArray):
    result.socialLinks = toSocialLinks(obj)