import app_service/service/profile/dto/profile_showcase_preferences

type
  ProfileShowcaseBaseItem* = object of RootObj
    showcaseVisibility*: ProfileShowcaseVisibility
    order*: int

proc showcaseVisibility*(self: ProfileShowcaseBaseItem): ProfileShowcaseVisibility {.inline.} =
  self.showcaseVisibility

proc order*(self: ProfileShowcaseBaseItem): int {.inline.} =
  self.order
