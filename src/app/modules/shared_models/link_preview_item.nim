import strformat
import ../../../app_service/service/message/dto/link_preview
import ../../../app_service/service/message/dto/status_community_link_preview
import ../../../app_service/service/message/dto/status_community_channel_link_preview

type
  Item* = ref object
    unfurled*: bool
    immutable*: bool
    linkPreview*: LinkPreview

proc delete*(self: Item) =
  self.linkPreview.delete

proc linkPreview*(self: Item): LinkPreview {.inline.} =
  return self.linkPreview

proc `linkPreview=`*(self: Item, linkPreview: LinkPreview) {.inline.} =
  self.linkPreview = linkPreview

proc `$`*(self: Item): string =
  result = fmt"""LinkPreviewItem(
    unfurled: {self.unfurled},
    immutable: {self.immutable},
    linkPreview: {self.linkPreview},
  )"""

proc getChannelCommunity*(self: Item): StatusCommunityLinkPreview =
  if self.linkPreview == nil:
    return nil
  if self.linkPreview.statusCommunityChannelPreview == nil:
    return nil
  return self.linkPreview.statusCommunityChannelPreview.getCommunity()
