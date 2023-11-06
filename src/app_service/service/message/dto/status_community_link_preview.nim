import json, strformat, NimQml, chronicles
import link_preview_thumbnail
import ../../community/dto/community

include ../../../common/json_utils

QtObject:
  type StatusCommunityLinkPreview* = ref object of QObject
    communityId: string
    displayName: string
    description: string
    membersCount: int
    activeMembersCount: int
    color: string
    icon: LinkPreviewThumbnail
    banner: LinkPreviewThumbnail

  proc setup*(self: StatusCommunityLinkPreview) =
    self.QObject.setup()
    self.icon = newLinkPreviewThumbnail()
    self.banner = newLinkPreviewThumbnail()

  proc delete*(self: StatusCommunityLinkPreview) =
    self.QObject.delete()
    self.icon.delete()
    self.banner.delete()


  proc communityIdChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getCommunityId*(self: StatusCommunityLinkPreview): string {.slot.} =
    result = self.communityId
  QtProperty[string] communityId:
    read = getCommunityId
    notify = communityIdChanged

  proc displayNameChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getDisplayName*(self: StatusCommunityLinkPreview): string {.slot.} =
    result = self.displayName
  QtProperty[string] displayName:
    read = getDisplayName
    notify = displayNameChanged

  proc descriptionChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getDescription*(self: StatusCommunityLinkPreview): string {.slot.} =
    result = self.description
  QtProperty[string] description:
    read = getDescription
    notify = descriptionChanged

  proc membersCountChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getMembersCount*(self: StatusCommunityLinkPreview): int {.slot.} =
    result = int(self.membersCount)
  QtProperty[int] membersCount:
    read = getMembersCount
    notify = membersCountChanged

  proc activeMembersCountChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getActiveMembersCount*(self: StatusCommunityLinkPreview): int {.slot.} =
    result = int(self.activeMembersCount)
  QtProperty[int] activeMembersCount:
    read = getActiveMembersCount
    notify = activeMembersCountChanged
  
  proc colorChanged*(self: StatusCommunityLinkPreview) {.signal.}
  proc getColor*(self: StatusCommunityLinkPreview): string {.slot.} =
    result = self.color
  QtProperty[string] color:
    read = getColor
    notify = colorChanged

  proc getIcon*(self: StatusCommunityLinkPreview): LinkPreviewThumbnail =
    result = self.icon

  proc getBanner*(self: StatusCommunityLinkPreview): LinkPreviewThumbnail =
    result = self.banner

  proc toStatusCommunityLinkPreview*(jsonObj: JsonNode): StatusCommunityLinkPreview =
    new(result, delete)
    result.setup()

    var icon: LinkPreviewThumbnail
    var banner: LinkPreviewThumbnail

    discard jsonObj.getProp("communityId", result.communityId)
    discard jsonObj.getProp("displayName", result.displayName)
    discard jsonObj.getProp("description", result.description)
    discard jsonObj.getProp("membersCount", result.membersCount)
    discard jsonObj.getProp("activeMembersCount", result.activeMembersCount)
    discard jsonObj.getProp("color", result.color)

    var iconJson: JsonNode
    if jsonObj.getProp("icon", iconJson):
      icon = toLinkPreviewThumbnail(iconJson)

    var bannerJson: JsonNode
    if jsonObj.getProp("banner", bannerJson):
      banner = toLinkPreviewThumbnail(bannerJson)

    result.icon.copy(icon)
    result.banner.copy(banner)

  proc `$`*(self: StatusCommunityLinkPreview): string =
    result = fmt"""StatusCommunityLinkPreview(
      communityId: {self.communityId},
      displayName: {self.displayName},
      description: {self.description},
      membersCount: {self.membersCount},
      activeMembersCount: {self.activeMembersCount},
      color: {self.color},
      icon: {self.icon},
      banner: {self.banner}
    )"""

  proc `%`*(self: StatusCommunityLinkPreview): JsonNode =
    result = %* {
      "communityId": self.communityId,
      "displayName": self.displayName,
      "description": self.description,
      "membersCount": self.membersCount,
      "activeMembersCount": self.activeMembersCount,
      "color": self.color,
      "icon": self.icon,
      "banner": self.banner
    }

  proc empty*(self: StatusCommunityLinkPreview): bool =
    return self.communityId.len == 0

  proc setCommunityInfo*(self: StatusCommunityLinkPreview, community: CommunityDto): bool =
    if self.communityId != community.id:
      return false

    debug "setCommunityInfo", communityId = self.communityId, communityName = community.name

    if self.displayName != community.name:
      self.displayName = community.name
      self.displayNameChanged()

    if self.description != community.description:
      self.description = community.description
      self.descriptionChanged()

    if self.membersCount != community.members.len:
      self.membersCount = community.members.len
      self.membersCountChanged()

    if self.activeMembersCount != community.activeMembersCount:
      self.activeMembersCount = int(community.activeMembersCount)
      self.activeMembersCountChanged()

    if self.color != community.color:
      self.color = community.color
      self.colorChanged()

    self.icon.update(0, 0, "", community.images.thumbnail)
    self.banner.update(0, 0, "", community.images.banner)

    return true
