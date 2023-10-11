import app_service/service/profile/dto/profile_showcase_entry

type
  ProfileShowcasePreferencesItem* = object
    id*: string
    entryType*: ProfileShowcaseEntryType
    visibility*: ProfileShowcaseVisibility
    order*: int
    name*: string
    secondaryTitle*: string
    image*: string
    emoji*: string
    colorId*: string
    color*: string
    backgroundColor*: string

# TODO: different init functions for different content
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

proc name*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.name

proc secondaryTitle*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.secondaryTitle

proc image*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.image

proc emoji*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.emoji

proc colorId*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.colorId

proc color*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.color

proc backgroundColor*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.backgroundColor
