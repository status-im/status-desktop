import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/wallet_account/dto/token_dto
import ../../../../shared_models/currency_amount

type
  ProfileShowcaseAssetItem* = ref object of ProfileShowcaseBaseItem
    name*: string
    enabledNetworkBalance*: CurrencyAmount
    visibleForNetworkWithPositiveBalance*: bool
    symbol*: string
    color*: string
    # TODO: marketValuesSummary

proc initProfileShowcaseAssetItem*(token: WalletTokenDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

  result.name = token.name

  result.enabledNetworkBalance = newCurrencyAmount(token.getTotalBalanceOfSupportedChains(), token.symbol, token.decimals, false)
  result.visibleForNetworkWithPositiveBalance = true;# TODO: from wallet section

  result.symbol = token.symbol
  result.color = token.color
  #TODO: from wallet section, using marketValuesSummary, currencyAmountToItem(marketValues.price, currencyFormat),

proc name*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.name

proc enabledNetworkBalance*(self: ProfileShowcaseAssetItem): CurrencyAmount {.inline.} =
  self.enabledNetworkBalance

proc visibleForNetworkWithPositiveBalance*(self: ProfileShowcaseAssetItem): bool {.inline.} =
  self.visibleForNetworkWithPositiveBalance

proc symbol*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.symbol

proc color*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.color
