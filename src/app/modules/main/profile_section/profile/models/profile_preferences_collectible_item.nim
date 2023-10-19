import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/token/dto

type
  ProfileShowcaseCollectibleItem* = ref object of ProfileShowcaseBaseItem
    name*: string
    collectionName*: string
    imageUrl*: string
    backgroundColor*: string


proc initProfileShowcaseCollectibleItem*(token: TokenDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseCollectibleItem =
  result = ProfileShowcaseCollectibleItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

  result.name = token.name
  # result.collectionName = TODO: community? name
  # result.imageUrl = TODO: Collectible image
  result.backgroundColor = token.color

proc name*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.name

proc collectionName*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.collectionName

proc imageUrl*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.imageUrl

proc backgroundColor*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.backgroundColor
