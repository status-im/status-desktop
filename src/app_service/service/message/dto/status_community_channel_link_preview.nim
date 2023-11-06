import json, strformat, NimQml, chronicles
import link_preview_thumbnail
import status_community_link_preview
import ../../community/dto/community
import ../../chat/dto/chat
include ../../../common/json_utils

QtObject:
  type StatusCommunityChannelLinkPreview* = ref object of QObject
    channelUuid: string
    emoji: string
    displayName: string
    description: string
    color: string
    community: StatusCommunityLinkPreview

  proc setup*(self: StatusCommunityChannelLinkPreview) =
    self.QObject.setup()

  proc delete*(self: StatusCommunityChannelLinkPreview) =
    self.QObject.delete()
    self.community.delete()

  proc channelUuidChanged*(self: StatusCommunityChannelLinkPreview) {.signal.}
  proc getChannelUuid*(self: StatusCommunityChannelLinkPreview): string {.slot.} =
    return self.channelUuid
  QtProperty[string] channelUuid:
    read = getChannelUuid
    notify = channelUuidChanged

  proc emojiChanged*(self: StatusCommunityChannelLinkPreview) {.signal.}
  proc getEmoji*(self: StatusCommunityChannelLinkPreview): string {.slot.} =
    return self.emoji
  QtProperty[string] emoji:
    read = getEmoji
    notify = emojiChanged

  proc displayNameChanged*(self: StatusCommunityChannelLinkPreview) {.signal.}
  proc getDisplayName*(self: StatusCommunityChannelLinkPreview): string {.slot.} =
    return self.displayName
  QtProperty[string] displayName:
    read = getDisplayName
    notify = displayNameChanged

  proc descriptionChanged*(self: StatusCommunityChannelLinkPreview) {.signal.}
  proc getDescription*(self: StatusCommunityChannelLinkPreview): string {.slot.} =
    return self.description
  QtProperty[string] description:
    read = getDescription
    notify = descriptionChanged

  proc colorChanged*(self: StatusCommunityChannelLinkPreview) {.signal.}
  proc getColor*(self: StatusCommunityChannelLinkPreview): string {.slot.} =
    return self.color
  QtProperty[string] color:
    read = getColor
    notify = colorChanged

  proc getCommunity*(self: StatusCommunityChannelLinkPreview): StatusCommunityLinkPreview =
    return self.community

  proc toStatusCommunityChannelLinkPreview*(jsonObj: JsonNode): StatusCommunityChannelLinkPreview =
    new(result, delete)
    result.setup()

    discard jsonObj.getProp("channelUuid", result.channelUuid)
    discard jsonObj.getProp("emoji", result.emoji)
    discard jsonObj.getProp("displayName", result.displayName)
    discard jsonObj.getProp("description", result.description)
    discard jsonObj.getProp("color", result.color)
  
    var communityJsonNode: JsonNode
    if jsonObj.getProp("community", communityJsonNode):
      result.community = toStatusCommunityLinkPreview(communityJsonNode)
  
  proc `$`*(self: StatusCommunityChannelLinkPreview): string =
    return fmt"""StatusCommunityChannelLinkPreview(
      channelUuid: {self.channelUuid},
      emoji: {self.emoji},
      displayName: {self.displayName},
      description: {self.description},
      color: {self.color},
      community: {self.community}
    )"""

  proc `%`*(self: StatusCommunityChannelLinkPreview): JsonNode =
    return %* {
      "channelUuid": self.channelUuid,
      "emoji": self.emoji,
      "displayName": self.displayName,
      "description": self.description,
      "color": self.color,
      "community": self.community
    }

  proc empty*(self: StatusCommunityChannelLinkPreview): bool =
    return self.channelUUID.len == 0

  proc setCommunityInfo*(self: StatusCommunityChannelLinkPreview, community: CommunityDto): bool =
    if not self.community.setCommunityInfo(community):
      return false

    for chat in community.chats:
      if chat.communityChannelUuid() != self.channelUuid:
        continue

      debug "setChannelInfo", communityId = $self.community.getCommunityId(), channelUuid = $self.channelUuid

      if self.displayName != chat.name:
        self.displayName = chat.name
        self.displayNameChanged()

      if self.description != chat.description:
        self.description = chat.description
        self.descriptionChanged()

      if self.emoji != chat.emoji:
        self.emoji = chat.emoji
        self.emojiChanged()

      if self.color != community.color:
        self.color = community.color
        self.colorChanged()

      return true
