import json, strutils, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/wallet_account/dto/account_dto
import app_service/service/profile/dto/profile_showcase_preferences

import app/modules/shared_models/currency_amount

include app_service/common/json_utils
include app_service/common/utils

import backend/helpers/token

type
  ProfileShowcaseAssetItem* = ref object of ProfileShowcaseBaseItem
    symbol*: string
    name*: string
    enabledNetworkBalance*: CurrencyAmount
    color*: string

proc initProfileShowcaseAssetItem*(token: WalletTokenDto, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  result.showcaseVisibility = visibility
  result.order = order

  result.symbol = token.symbol
  result.name = token.name
  result.enabledNetworkBalance = newCurrencyAmount(token.getTotalBalanceOfSupportedChains(), token.symbol, token.decimals, false)
  result.color = token.color

proc toProfileShowcaseAssetItem*(jsonObj: JsonNode): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("color", result.color)

  result.enabledNetworkBalance = jsonObj{"enabledNetworkBalance"}.toCurrencyAmount()

proc toShowcasePreferenceItem*(self: ProfileShowcaseAssetItem): ProfileShowcaseAssetPreference =
  result = ProfileShowcaseAssetPreference()

  result.symbol = self.symbol
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc symbol*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.symbol

proc name*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.name

proc enabledNetworkBalance*(self: ProfileShowcaseAssetItem): CurrencyAmount {.inline.} =
  self.enabledNetworkBalance

proc color*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.color
