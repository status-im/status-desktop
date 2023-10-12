import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/wallet_account/dto/account_dto

type
  ProfileShowcaseAccountItem* = object
    id*: string
    entryType*: ProfileShowcaseEntryType
    showcaseVisibility*: ProfileShowcaseVisibility
    order*: int

    name*: string
    address*: string
    emoji*: string
    walletType*: string
    colorId*: string

proc initProfileShowcaseAccountItem*(account: WalletAccountDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseAccountItem =
  result = ProfileShowcaseAccountItem()

  result.id = account.address
  result.name = account.name
  result.address = account.address
  result.emoji = account.emoji
  result.walletType = account.walletType
  result.colorId = account.colorId

  result.entryType = entry.entryType
  result.showcaseVisibility = entry.visibility
  result.order = entry.order

proc id*(self: ProfileShowcaseAccountItem): string {.inline.} =
  self.id

proc entryType*(self: ProfileShowcaseAccountItem): ProfileShowcaseEntryType {.inline.} =
  self.entryType

proc showcaseVisibility*(self: ProfileShowcaseAccountItem): ProfileShowcaseVisibility {.inline.} =
  self.showcaseVisibility

proc order*(self: ProfileShowcaseAccountItem): int {.inline.} =
  self.order

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
