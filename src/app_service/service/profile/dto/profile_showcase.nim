import json, json_serialization

include ../../../common/json_utils

type ProfileShowcaseCommunity* = ref object of RootObj
  communityId*: string
  order*: int

type ProfileShowcaseAccount* = ref object of RootObj
  address*: string
  name*: string
  colorId*: string
  emoji*: string
  order*: int

type ProfileShowcaseCollectible* = ref object of RootObj
  uid*: string
  order*: int

type ProfileShowcaseAsset* = ref object of RootObj
  symbol*: string
  order*: int

type ProfileShowcaseDto* = ref object of RootObj
  contactId*: string
  communities*: seq[ProfileShowcaseCommunity]
  accounts*: seq[ProfileShowcaseAccount]
  collectibles*: seq[ProfileShowcaseCollectible]
  assets*: seq[ProfileShowcaseAsset]

proc toProfileShowcaseCommunity*(jsonObj: JsonNode): ProfileShowcaseCommunity =
  result = ProfileShowcaseCommunity()
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseAccount*(jsonObj: JsonNode): ProfileShowcaseAccount =
  result = ProfileShowcaseAccount()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("colorId", result.colorId)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseCollectible*(jsonObj: JsonNode): ProfileShowcaseCollectible =
  result = ProfileShowcaseCollectible()
  discard jsonObj.getProp("uid", result.uid)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseAsset*(jsonObj: JsonNode): ProfileShowcaseAsset =
  result = ProfileShowcaseAsset()
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseDto*(jsonObj: JsonNode): ProfileShowcaseDto =
  result = ProfileShowcaseDto()

  discard jsonObj.getProp("contactId", result.contactId)

  for jsonMsg in jsonObj["communities"]:
    result.communities.add(jsonMsg.toProfileShowcaseCommunity())
  for jsonMsg in jsonObj["accounts"]:
    result.accounts.add(jsonMsg.toProfileShowcaseAccount())
  for jsonMsg in jsonObj["collectibles"]:
    result.collectibles.add(jsonMsg.toProfileShowcaseCollectible())
  for jsonMsg in jsonObj["assets"]:
    result.assets.add(jsonMsg.toProfileShowcaseAsset())
