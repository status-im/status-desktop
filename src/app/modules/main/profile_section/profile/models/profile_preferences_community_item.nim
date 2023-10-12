import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/community/dto/community
import app_service/common/types

type
  ProfileShowcaseCommunityItem* = object
    id*: string
    entryType*: ProfileShowcaseEntryType
    showcaseVisibility*: ProfileShowcaseVisibility
    order*: int

    name*: string
    memberRole*: MemberRole
    image*: string
    color*: string

proc initProfileShowcaseCommunityItem*(community: CommunityDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  result.id = community.id
  result.name = community.name
  result.memberRole = community.memberRole
  result.image = community.images.thumbnail
  result.color = community.color

  result.entryType = entry.entryType
  result.showcaseVisibility = entry.visibility
  result.order = entry.order

proc id*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.id

proc entryType*(self: ProfileShowcaseCommunityItem): ProfileShowcaseEntryType {.inline.} =
  self.entryType

proc showcaseVisibility*(self: ProfileShowcaseCommunityItem): ProfileShowcaseVisibility {.inline.} =
  self.showcaseVisibility

proc order*(self: ProfileShowcaseCommunityItem): int {.inline.} =
  self.order

proc name*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.name

proc memberRole*(self: ProfileShowcaseCommunityItem): MemberRole {.inline.} =
  self.memberRole

proc image*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.image

proc color*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.color
