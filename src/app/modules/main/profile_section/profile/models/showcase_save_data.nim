import json, strutils, sequtils

include app_service/common/json_utils
include app_service/common/utils

import app_service/service/profile/dto/profile_showcase_preferences

type ShowcaseSaveEntry* = ref object of RootObj
  showcaseKey*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  showcasePosition*: int

type ShowcaseSaveSocialLink* = ref object of RootObj
  url*: string
  text*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  showcasePosition*: int

type ShowcaseSaveData* = ref object of RootObj
  communities*: seq[ShowcaseSaveEntry]
  accounts*: seq[ShowcaseSaveEntry]
  collectibles*: seq[ShowcaseSaveEntry]
  assets*: seq[ShowcaseSaveEntry]
  socialLinks*: seq[ShowcaseSaveSocialLink]

proc toShowcaseSaveEntry*(jsonObj: JsonNode): ShowcaseSaveEntry =
  result = ShowcaseSaveEntry()
  discard jsonObj.getProp("showcaseKey", result.showcaseKey)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()
  discard jsonObj.getProp("showcasePosition", result.showcasePosition)

proc toShowcaseSaveEntries*(jsonObj: JsonNode, entry: string): seq[ShowcaseSaveEntry] =
  var entries: seq[ShowcaseSaveEntry] = @[]
  if jsonObj{entry} != nil and jsonObj{entry}.kind != JNull:
    for jsonMsg in jsonObj{entry}:
      entries.add(jsonMsg.toShowcaseSaveEntry())
  return entries

proc toShowcaseSaveSocialLink*(jsonObj: JsonNode): ShowcaseSaveSocialLink =
  result = ShowcaseSaveSocialLink()
  discard jsonObj.getProp("url", result.url)
  discard jsonObj.getProp("text", result.text)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()
  discard jsonObj.getProp("showcasePosition", result.showcasePosition)

proc toShowcaseSaveSocialLinks*(jsonObj: JsonNode): seq[ShowcaseSaveSocialLink] =
  var socialLinks: seq[ShowcaseSaveSocialLink] = @[]
  if jsonObj{"socialLinks"} != nil and jsonObj{"socialLinks"}.kind != JNull:
    for jsonMsg in jsonObj{"socialLinks"}:
      socialLinks.add(jsonMsg.toShowcaseSaveSocialLink())
  return socialLinks

proc toShowcaseSaveData*(jsonObj: JsonNode): ShowcaseSaveData =
  result = ShowcaseSaveData()
  result.communities = toShowcaseSaveEntries(jsonObj, "communities")
  result.accounts = toShowcaseSaveEntries(jsonObj, "accounts")
  result.collectibles = toShowcaseSaveEntries(jsonObj, "collectibles")
  result.assets = toShowcaseSaveEntries(jsonObj, "assets")
  result.socialLinks = toShowcaseSaveSocialLinks(jsonObj)
