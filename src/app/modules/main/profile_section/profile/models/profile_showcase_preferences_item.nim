import app_service/service/profile/dto/profile_showcase_preferences

type
  ProfileShowcasePreferencesItem* = object of RootObj
    showcaseKey*: string
    showcaseVisibility*: ProfileShowcaseVisibility
    showcasePosition*: int

proc initProfileShowcasePreferencesItem*(key: string, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcasePreferencesItem =
  result = ProfileShowcasePreferencesItem()

  result.showcaseKey = key
  result.showcasePosition = order
  result.showcaseVisibility = visibility

proc showcaseKey*(self: ProfileShowcasePreferencesItem): string {.inline.} =
  self.showcaseKey

proc showcaseVisibility*(self: ProfileShowcasePreferencesItem): ProfileShowcaseVisibility {.inline.} =
  self.showcaseVisibility

proc showcasePosition*(self: ProfileShowcasePreferencesItem): int {.inline.} =
  self.showcasePosition
