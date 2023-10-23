import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/wallet_account/dto/account_dto

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseAccountItem* = ref object of ProfileShowcaseBaseItem
    address*: string
    name*: string
    emoji*: string
    walletType*: string
    colorId*: string

# proc initProfileShowcaseAccountItem*(account: WalletAccountDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAccountItem =
#   result = ProfileShowcaseAccountItem()

#   result.showcaseVisibility = entry.showcaseVisibility
#   result.order = entry.order

#   result.address = account.address
#   result.name = account.name
#   result.emoji = account.emoji
#   result.walletType = account.walletType
#   result.colorId = account.colorId

proc toProfileShowcaseAccountItem*(jsonObj: JsonNode): ProfileShowcaseAccountItem =
  result = ProfileShowcaseAccountItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("walletType", result.walletType)
  discard jsonObj.getProp("colorId", result.colorId)

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
