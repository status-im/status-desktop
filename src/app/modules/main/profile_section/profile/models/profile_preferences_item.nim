import app_service/service/profile/dto/profile_showcase_entry

type
  ProfileShowcasePreferencesItem* = object
    id*: string
    entryType*: ProfileShowcaseEntryType
    visibility*: ProfileShowcaseVisibility
    order*: int

proc initProfileShowcasePreferencesItem*(dto: ProfileShowcaseEntryDto): ProfileShowcasePreferencesItem =
  result = ProfileShowcasePreferencesItem()
  result.id = dto.id
  result.entryType = dto.entryType
  result.visibility = dto.visibility
  result.order = dto.order

proc id*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.id

proc entryType*(self: ProfileShowcasePreferencesItem): ProfileShowcaseEntryType {.inline.} =
  self.entryType

proc visibility*(self: ProfileShowcasePreferencesItem): ProfileShowcaseVisibility {.inline.} =
  self.visibility

proc order*(self: ProfileShowcasePreferencesItem): int {.inline.} =
  self.order