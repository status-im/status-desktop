import app_service/service/profile/dto/profile_showcase_entry

type
  ProfileShowcaseBaseItem* = object of RootObj
    id*: string
    entryType*: ProfileShowcaseEntryType
    showcaseVisibility*: ProfileShowcaseVisibility
    order*: int

proc id*(self: ProfileShowcaseBaseItem): string {.inline.} =
  self.id

proc entryType*(self: ProfileShowcaseBaseItem): ProfileShowcaseEntryType {.inline.} =
  self.entryType

proc showcaseVisibility*(self: ProfileShowcaseBaseItem): ProfileShowcaseVisibility {.inline.} =
  self.showcaseVisibility

proc order*(self: ProfileShowcaseBaseItem): int {.inline.} =
  self.order
