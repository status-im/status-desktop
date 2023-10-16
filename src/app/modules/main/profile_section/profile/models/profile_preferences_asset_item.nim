import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/token/dto

type
  ProfileShowcaseAssetItem* = ref object of ProfileShowcaseBaseItem
    name*: string
    enabledNetworkBalance*: string
    symbol*: string
    color*: string


proc initProfileShowcaseAssetItem*(token: TokenDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAssetItem =
  result = ProfileShowcaseAssetItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.visibility
  result.order = entry.order

  result.name = token.name
  # result.enabledNetworkBalance = TODO: how to calculate?
  # result.imageUrl = TODO: Asset symbol
  result.color = token.color

proc name*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.name

proc enabledNetworkBalance*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.enabledNetworkBalance

proc symbol*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.symbol

proc color*(self: ProfileShowcaseAssetItem): string {.inline.} =
  self.color
