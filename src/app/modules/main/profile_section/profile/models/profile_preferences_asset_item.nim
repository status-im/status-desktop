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
    contractAddress*: string
    communityId*: string
    chainId*: string
    symbol*: string
    name*: string
    enabledNetworkBalance*: CurrencyAmount
    color*: string
    decimals*: int

proc initProfileShowcaseAssetItem*(token: WalletTokenDto, contractAddress: string, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  result.showcaseVisibility = visibility
  result.order = order

  result.contractAddress = contractAddress
  # TODO: result.chainId = token.chainId
  result.communityId = token.communityId
  result.symbol = token.symbol
  result.name = token.name
  result.enabledNetworkBalance = newCurrencyAmount(token.getTotalBalanceOfSupportedChains(), token.symbol, token.decimals, false)
  result.color = token.color
  result.decimals = token.decimals

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
  discard jsonObj.getProp("color", result.color)
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
