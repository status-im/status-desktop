import json, strutils, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/community/dto/community
import app_service/service/profile/dto/profile_showcase_preferences

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseCommunityItem* = ref object of ProfileShowcaseBaseItem
    id*: string
    name*: string
    memberRole*: MemberRole
    image*: string
    color*: string
    description*: string
    membersCount*: int
    loading*: bool

proc initProfileShowcaseCommunityItem*(community: CommunityDto, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  result.showcaseVisibility = visibility
  result.order = order

  result.id = community.id
  result.name = community.name
  result.memberRole = community.memberRole
  result.image = community.images.thumbnail
  result.color = community.color
  result.description = community.description
  result.membersCount = len(community.members)
  result.loading = false

proc initProfileShowcaseCommunityLoadingItem*(communityId: string, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  result.showcaseVisibility = visibility
  result.order = order
  result.id = communityId
  result.loading = true

proc toProfileShowcaseCommunityItem*(jsonObj: JsonNode): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("memberRole", result.memberRole)
  discard jsonObj.getProp("image", result.image)
  discard jsonObj.getProp("color", result.color)
  result.loading = false

proc toShowcasePreferenceItem*(self: ProfileShowcaseCommunityItem): ProfileShowcaseCommunityPreference =
  result = ProfileShowcaseCommunityPreference()

  result.communityId = self.id
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc patchFromCommunity*(self: ProfileShowcaseCommunityItem, community: CommunityDto) =
  self.name = community.name
  self.memberRole = community.memberRole
  self.image = community.images.thumbnail
  self.color = community.color
  self.description = community.description
  self.membersCount = len(community.members)
  self.loading = false

proc name*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.name

proc memberRole*(self: ProfileShowcaseCommunityItem): MemberRole {.inline.} =
  self.memberRole

proc image*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.image

proc color*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.color
