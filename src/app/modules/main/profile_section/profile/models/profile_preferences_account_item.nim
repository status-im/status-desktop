import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/wallet_account/dto/account_dto

type
  ProfileShowcaseAccountItem* = ref object of ProfileShowcaseBaseItem
    name*: string
    address*: string
    emoji*: string
    walletType*: string
    colorId*: string

proc initProfileShowcaseAccountItem*(account: WalletAccountDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAccountItem =
  result = ProfileShowcaseAccountItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

  result.name = account.name
  result.address = account.address
  result.emoji = account.emoji
  result.walletType = account.walletType
  result.colorId = account.colorId

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
