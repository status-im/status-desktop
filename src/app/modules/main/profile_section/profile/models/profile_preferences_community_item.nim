import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/community/dto/community
import app_service/common/types

type
  ProfileShowcaseCommunityItem* = ref object of ProfileShowcaseBaseItem
    name*: string
    memberRole*: MemberRole
    image*: string
    color*: string

proc initProfileShowcaseCommunityItem*(community: CommunityDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  result.id = entry.id
  result.entryType = entry.entryType
  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

  result.name = community.name
  result.memberRole = community.memberRole
  result.image = community.images.thumbnail
  result.color = community.color

proc name*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.name

proc memberRole*(self: ProfileShowcaseCommunityItem): MemberRole {.inline.} =
  self.memberRole

proc image*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.image

proc color*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.color
