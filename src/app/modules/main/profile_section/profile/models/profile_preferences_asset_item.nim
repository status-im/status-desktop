import json, strutils, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_preferences
import app_service/service/token/service_items

import app/modules/shared_models/currency_amount

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseAssetItem* = ref object of ProfileShowcaseBaseItem
    contractAddress*: string
    communityId*: string
    chainId*: int
    symbol*: string
    name*: string
    enabledNetworkBalance*: CurrencyAmount
    decimals*: int


proc initProfileShowcaseVerifiedToken*(token: TokenBySymbolItem, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  result.showcaseVisibility = visibility
  result.order = order

  result.symbol = token.symbol
  result.name = token.name
  result.enabledNetworkBalance = newCurrencyAmount()
  result.decimals = token.decimals

  # TODO: initProfileShowcaseUnverifiedToken

proc toProfileShowcaseAssetItem*(jsonObj: JsonNode): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("address", result.contractAddress)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("decimals", result.decimals)

  result.enabledNetworkBalance = newCurrencyAmount(jsonObj{"enabledNetworkBalance"}.getFloat, result.symbol, result.decimals, false)

proc toShowcaseVerifiedTokenPreference*(self: ProfileShowcaseAssetItem): ProfileShowcaseVerifiedTokenPreference =
  result = ProfileShowcaseVerifiedTokenPreference()

  result.symbol = self.symbol
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc toShowcaseUnverifiedTokenPreference*(self: ProfileShowcaseAssetItem): ProfileShowcaseUnverifiedTokenPreference =
  result = ProfileShowcaseUnverifiedTokenPreference()

  result.contractAddress = self.contractAddress
  result.chainId = self.chainId
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order
