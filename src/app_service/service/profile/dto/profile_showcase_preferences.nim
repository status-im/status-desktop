import json, strutils, stint, sequtils, json_serialization

include ../../../common/json_utils
include ../../../common/utils

type ProfileShowcaseVisibility* {.pure.}= enum
  ToNoOne = 0,
  ToIDVerifiedContacts = 1,
  ToContacts = 2,
  ToEveryone = 3,

type ProfileShowcaseCommunityPreference* = ref object of RootObj
  communityId*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcaseAccountPreference* = ref object of RootObj
  address*: string
  name*: string
  colorId*: string
  emoji*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcaseCollectiblePreference* = ref object of RootObj
  uid*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcaseAssetPreference* = ref object of RootObj
  symbol*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcasePreferencesDto* = ref object of RootObj
  communities*: seq[ProfileShowcaseCommunityPreference]
  accounts*: seq[ProfileShowcaseAccountPreference]
  collectibles*: seq[ProfileShowcaseCollectiblePreference]
  assets*: seq[ProfileShowcaseAssetPreference]

proc toProfileShowcaseVisibility*(jsonObj: JsonNode): ProfileShowcaseVisibility =
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      return ProfileShowcaseVisibility(visibilityInt)
  return ProfileShowcaseVisibility.ToNoOne

proc toProfileShowcaseCommunityPreference*(jsonObj: JsonNode): ProfileShowcaseCommunityPreference =
  result = ProfileShowcaseCommunityPreference()
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseCommunityPreference): JsonNode =
  %* {
    "communityId": self.communityId,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcaseAccountPreference*(jsonObj: JsonNode): ProfileShowcaseAccountPreference =
  result = ProfileShowcaseAccountPreference()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("colorId", result.colorId)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseAccountPreference): JsonNode =
  %* {
    "address": self.address,
    "name": self.name,
    "colorId": self.colorId,
    "emoji": self.emoji,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcaseCollectiblePreference*(jsonObj: JsonNode): ProfileShowcaseCollectiblePreference =
  result = ProfileShowcaseCollectiblePreference()
  discard jsonObj.getProp("uid", result.uid)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseCollectiblePreference): JsonNode =
  %* {
    "uid": self.uid,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcaseAssetPreference*(jsonObj: JsonNode): ProfileShowcaseAssetPreference =
  result = ProfileShowcaseAssetPreference()
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseAssetPreference): JsonNode =
  %* {
    "symbol": self.symbol,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcasePreferencesDto*(jsonObj: JsonNode): ProfileShowcasePreferencesDto =
  result = ProfileShowcasePreferencesDto()

  for jsonMsg in jsonObj["communities"]:
    result.communities.add(jsonMsg.toProfileShowcaseCommunityPreference())
  for jsonMsg in jsonObj["accounts"]:
    result.accounts.add(jsonMsg.toProfileShowcaseAccountPreference())
  for jsonMsg in jsonObj["collectibles"]:
    result.collectibles.add(jsonMsg.toProfileShowcaseCollectiblePreference())
  for jsonMsg in jsonObj["assets"]:
    result.assets.add(jsonMsg.toProfileShowcaseAssetPreference())

proc toJsonNode*(self: ProfileShowcasePreferencesDto): JsonNode =
  let communities = self.communities.map(entry => entry.toJsonNode())
  let accounts = self.accounts.map(entry => entry.toJsonNode())
  let collectibles = self.collectibles.map(entry => entry.toJsonNode())
  let assets = self.assets.map(entry => entry.toJsonNode())

  return %*[{
    "communities": communities,
    "accounts": accounts,
    "collectibles": collectibles,
    "assets": assets,
  }]
