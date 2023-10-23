import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/token/dto

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseCollectibleItem* = ref object of ProfileShowcaseBaseItem
    uid*: string
    name*: string
    collectionName*: string
    imageUrl*: string
    backgroundColor*: string


# proc initProfileShowcaseCollectibleItem*(token: TokenDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseCollectibleItem =
#   result = ProfileShowcaseCollectibleItem()

#   result.showcaseVisibility = entry.showcaseVisibility
#   result.order = entry.order

#   result.name = token.name
#   # result.collectionName = TODO: community? name
#   # result.imageUrl = TODO: Collectible image
#   result.backgroundColor = token.color

proc toProfileShowcaseCollectibleItem*(jsonObj: JsonNode): ProfileShowcaseCollectibleItem =
  result = ProfileShowcaseCollectibleItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("uid", result.uid)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("collectionName", result.collectionName)
  discard jsonObj.getProp("imageUrl", result.imageUrl)
  discard jsonObj.getProp("backgroundColor", result.backgroundColor)

proc getEntryDto*(self: ProfileShowcaseCollectibleItem): ProfileShowcaseEntryDto =
  result = ProfileShowcaseEntryDto()
  result.id = self.uid
  result.entryType = ProfileShowcaseEntryType.Collectible
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc name*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.name

proc collectionName*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.collectionName

proc imageUrl*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.imageUrl

proc backgroundColor*(self: ProfileShowcaseCollectibleItem): string {.inline.} =
  self.backgroundColor
