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

proc secondaryTitle*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.secondaryTitle

proc image*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.image

proc emoji*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.emoji

proc colorId*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.colorId

proc color*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.color

proc backgroundColor*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.backgroundColor
