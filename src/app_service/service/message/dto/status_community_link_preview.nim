import json, strformat, NimQml, chronicles
import link_preview_thumbnail
include ../../../common/json_utils

QtObject:
  type StatusCommunityLinkPreview* = ref object of QObject
    communityID: string
    displayName: string
    description: string
    membersCount: int
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
    result = self.communityID
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

    discard jsonObj.getProp("communityId", result.communityID)
    discard jsonObj.getProp("displayName", result.displayName)
    discard jsonObj.getProp("description", result.description)
    discard jsonObj.getProp("membersCount", result.membersCount)
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
      communityId: {self.communityID},
      displayName: {self.displayName},
      description: {self.description},
      membersCount: {self.membersCount},
      color: {self.color},
      icon: {self.icon},
      banner: {self.banner}
    )"""

  proc `%`*(self: StatusCommunityLinkPreview): JsonNode =
    result = %* {
      "communityID": self.communityID,
      "displayName": self.displayName,
      "description": self.description,
      "membersCount": self.membersCount,
      "color": self.color,
      "icon": self.icon,
      "banner": self.banner
    }

  proc empty*(self: StatusCommunityLinkPreview): bool =
    return self.communityID.len == 0
