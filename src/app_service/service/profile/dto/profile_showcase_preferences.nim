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
  chainId*: string
  tokenId*: string
  contractAddress*: string
  communityId*: string
  accountAddress*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcaseVerifiedTokenPreference* = ref object of RootObj
  symbol*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcaseUnverifiedTokenPreference* = ref object of RootObj
  contractAddress*: string
  chainId*: string
  showcaseVisibility*: ProfileShowcaseVisibility
  order*: int

type ProfileShowcasePreferencesDto* = ref object of RootObj
  communities*: seq[ProfileShowcaseCommunityPreference]
  accounts*: seq[ProfileShowcaseAccountPreference]
  collectibles*: seq[ProfileShowcaseCollectiblePreference]
  verifiedTokens*: seq[ProfileShowcaseVerifiedTokenPreference]
  unverifiedTokens*: seq[ProfileShowcaseUnverifiedTokenPreference]

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
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("tokenId", result.tokenId)
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("accountAddress", result.accountAddress)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseCollectiblePreference): JsonNode =
  %* {
    "chainId": self.chainId,
    "tokenId": self.tokenId,
    "contractAddress": self.contractAddress,
    "communityId": self.communityId,
    "accountAddress": self.accountAddress,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcaseVerifiedTokenPreference*(jsonObj: JsonNode): ProfileShowcaseVerifiedTokenPreference =
  result = ProfileShowcaseVerifiedTokenPreference()
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseVerifiedTokenPreference): JsonNode =
  %* {
    "symbol": self.symbol,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }

proc toProfileShowcaseUnverifiedTokenPreference*(jsonObj: JsonNode): ProfileShowcaseUnverifiedTokenPreference =
  result = ProfileShowcaseUnverifiedTokenPreference()
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("order", result.order)
  result.showcaseVisibility = jsonObj.toProfileShowcaseVisibility()

proc toJsonNode*(self: ProfileShowcaseUnverifiedTokenPreference): JsonNode =
  %* {
    "contractAddress": self.contractAddress,
    "chainId": self.chainId,
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
  for jsonMsg in jsonObj["verifiedTokens"]:
    result.verifiedTokens.add(jsonMsg.toProfileShowcaseVerifiedTokenPreference())
  for jsonMsg in jsonObj["unverifiedTokens"]:
    result.unverifiedTokens.add(jsonMsg.toProfileShowcaseUnverifiedTokenPreference())

proc toJsonNode*(self: ProfileShowcasePreferencesDto): JsonNode =
  let communities = self.communities.map(entry => entry.toJsonNode())
  let accounts = self.accounts.map(entry => entry.toJsonNode())
  let collectibles = self.collectibles.map(entry => entry.toJsonNode())
  let verifiedTokens = self.verifiedTokens.map(entry => entry.toJsonNode())
  let unverifiedTokens = self.unverifiedTokens.map(entry => entry.toJsonNode())

  return %*[{
    "communities": communities,
    "accounts": accounts,
    "collectibles": collectibles,
    "verifiedTokens": verifiedTokens,
    "unverifiedTokens": unverifiedTokens
  }]
