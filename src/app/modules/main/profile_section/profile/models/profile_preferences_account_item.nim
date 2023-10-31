import json, strutils, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_preferences

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseAccountItem* = ref object of ProfileShowcaseBaseItem
    address*: string
    name*: string
    emoji*: string
    colorId*: string

proc initProfileShowcaseAccountItem*(
    address: string,
    name: string,
    emoji: string,
    colorId: string,
    visibility: ProfileShowcaseVisibility,
    order: int): ProfileShowcaseAccountItem =
  result = ProfileShowcaseAccountItem()

  result.address = address
  result.name = name
  result.emoji = emoji
  result.colorId = colorId
  result.showcaseVisibility = visibility
  result.order = order

proc toProfileShowcaseAccountItem*(jsonObj: JsonNode): ProfileShowcaseAccountItem =
  result = ProfileShowcaseAccountItem()

  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("colorId", result.colorId)

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

proc toShowcasePreferenceItem*(self: ProfileShowcaseAccountItem): ProfileShowcaseAccountPreference =
  result = ProfileShowcaseAccountPreference()

  result.address = self.address
  result.name = self.name
  result.emoji = self.emoji
  result.colorId = self.colorId
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc name*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.name

proc address*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.address

proc walletType*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.walletType

proc emoji*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.emoji

proc colorId*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.colorId
