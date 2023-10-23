import json, strformat, strutils, json_serialization

import profile_preferences_base_item
import app_service/service/profile/dto/profile_showcase_entry

# NOTE: temporary class to present profile showcaser item without data
type
  ProfileShowcaseSourceItem* = ref object of ProfileShowcaseBaseItem
    id*: string
    entryType*: ProfileShowcaseEntryType

proc toProfileShowcaseSourceItem*(entry: ProfileShowcaseEntryDto): ProfileShowcaseSourceItem =
  result = ProfileShowcaseSourceItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

proc toQmlJson*(self: ProfileShowcaseSourceItem): JsonNode =
  %* {
    "id": self.id,
    "entryType": self.entryType.int,
    "showcaseVisibility": self.showcaseVisibility.int,
    "order": self.order,
  }


proc id*(self: ProfileShowcaseSourceItem): string {.inline.} =
  self.id

proc entryType*(self: ProfileShowcaseSourceItem): ProfileShowcaseEntryType {.inline.} =
  self.entryType
