import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/wallet_account/dto/token_dto
import ../../../../shared_models/currency_amount

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseAssetItem* = ref object of ProfileShowcaseBaseItem
    symbol*: string
    name*: string
    enabledNetworkBalance*: CurrencyAmount
    visibleForNetworkWithPositiveBalance*: bool
    color*: string

# proc initProfileShowcaseAssetItem*(token: WalletTokenDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAssetItem =
#   result = ProfileShowcaseAssetItem()

#   result.showcaseVisibility = entry.showcaseVisibility
#   result.order = entry.order

#   result.symbol = token.symbol
#   result.name = token.name
#   result.enabledNetworkBalance = newCurrencyAmount(token.getTotalBalanceOfSupportedChains(), token.symbol, token.decimals, false)
#   result.visibleForNetworkWithPositiveBalance = true; # TODO: from wallet section
#   result.color = token.color

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
  discard jsonObj.getProp("visibleForNetworkWithPositiveBalance", result.visibleForNetworkWithPositiveBalance)
  discard jsonObj.getProp("color", result.color)

  result.enabledNetworkBalance = jsonObj{"enabledNetworkBalance"}.toCurrencyAmount()

proc symbol*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.symbol

proc name*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.name

proc enabledNetworkBalance*(self: ProfileShowcaseAssetItem): CurrencyAmount {.inline.} =
  self.enabledNetworkBalance

proc visibleForNetworkWithPositiveBalance*(self: ProfileShowcaseAssetItem): bool {.inline.} =
  self.visibleForNetworkWithPositiveBalance

proc color*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.color
