import json, strformat, tables
import ./link_preview_thumbnail, ./status_link_preview, ./standard_link_preview
import ./status_contact_link_preview, ./status_community_link_preview, ./status_community_channel_link_preview
include ../../../common/json_utils


type
  PreviewType {.pure.} = enum
    NoPreiew = 0
    StandardPreview
    StatusContactPreview
    StatusCommunityPreview
    StatusCommunityChannelPreview

  LinkPreview* = ref object
    url*: string
    previewType*: PreviewType
    standardPreview*: StandardLinkPreview
    statusContactPreview*: StatusContactLinkPreview
    statusCommunityPreview*: StatusCommunityLinkPreview
    statusCommunityChannelPreview*: StatusCommunityChannelLinkPreview

proc delete*(self: LinkPreview) =
  if self.standardPreview != nil:
    self.standardPreview.delete
  if self.statusContactPreview != nil:
    self.statusContactPreview.delete
  if self.statusCommunityPreview != nil:
    self.statusCommunityPreview.delete
  if self.statusCommunityChannelPreview != nil:
    self.statusCommunityChannelPreview.delete

proc initLinkPreview*(url: string): LinkPreview =
  result = LinkPreview()
  result.url = url
  result.previewType = PreviewType.NoPreiew

proc toLinkPreview*(jsonObj: JsonNode, standard: bool): LinkPreview =
  result = LinkPreview()
  result.previewType = PreviewType.NoPreiew

  if standard:
    discard jsonObj.getProp("url", result.url)
    result.previewType = PreviewType.StandardPreview
    result.standardPreview = toStandardLinkPreview(jsonObj)
  else:
    discard jsonObj.getProp("url", result.url)
    var node: JsonNode
    if jsonObj.getProp("contact", node):
      result.previewType = PreviewType.StatusContactPreview
      result.statusContactPreview = toStatusContactLinkPreview(node)
    elif jsonObj.getProp("community", node):
      result.previewType = PreviewType.StatusCommunityPreview
      result.statusCommunityPreview = toStatusCommunityLinkPreview(node)
    elif jsonObj.getProp("channel", node):
      result.previewType = PreviewType.StatusCommunityChannelPreview
      result.statusCommunityChannelPreview = toStatusCommunityChannelLinkPreview(node)

proc `$`*(self: LinkPreview): string =
  let standardPreview = if self.standardPreview != nil: $self.standardPreview else: ""
  let contactPreview = if self.statusContactPreview != nil: $self.statusContactPreview else: ""
  let communityPreview = if self.statusCommunityPreview != nil: $self.statusCommunityPreview else: ""
  let channelPreview = if self.statusCommunityChannelPreview != nil: $self.statusCommunityChannelPreview else: ""
  result = fmt"""LinkPreview(
    url: {self.url},
    previewType: {self.previewType},
    standardPreview: {standardPreview},
    contactPreview: {contactPreview},
    communityPreview: {communityPreview},
    channelPreview: {channelPreview}
  )"""

proc `%`*(self: LinkPreview): JsonNode =
  result = %* {
    "url": self.url,
    "standardPreview": %self.standardPreview,
    "contactPreview": %self.statusContactPreview,
    "communityPreview": %self.statusCommunityPreview,
    "channelPreview": %self.statusCommunityChannelPreview
  }

proc empty*(self: LinkPreview): bool =
  case self.previewType:
    of PreviewType.StandardPreview:
      return self.standardPreview == nil or self.standardPreview.empty()
    of PreviewType.StatusContactPreview:
      return self.statusContactPreview == nil or self.statusContactPreview.empty()
    of PreviewType.StatusCommunityPreview:
      return self.statusCommunityPreview == nil or self.statusCommunityPreview.empty()
    of PreviewType.StatusCommunityChannelPreview:
      return self.statusCommunityChannelPreview == nil or self.statusCommunityChannelPreview.empty()
    else:
      return true

proc extractLinkPreviewsLists*(input: seq[LinkPreview]): (seq[StandardLinkPreview], seq[StatusLinkPreview]) =
  var standard: seq[StandardLinkPreview]
  var status: seq[StatusLinkPreview]

  for preview in input:
    case preview.previewType:
      of PreviewType.StandardPreview:
        if preview.standardPreview != nil:
          preview.standardPreview.url = preview.url
          standard.add(preview.standardPreview)
      of PreviewType.StatusContactPreview:
        let statusLinkPreview = StatusLinkPreview()
        statusLinkPreview.url = preview.url
        statusLinkPreview.contact = preview.statusContactPreview
        status.add(statusLinkPreview)
      of PreviewType.StatusCommunityPreview:
        let statusLinkPreview = StatusLinkPreview()
        statusLinkPreview.url = preview.url
        statusLinkPreview.community = preview.statusCommunityPreview
        status.add(statusLinkPreview)
      of PreviewType.StatusCommunityChannelPreview:
        let statusLinkPreview = StatusLinkPreview()
        statusLinkPreview.url = preview.url
        statusLinkPreview.channel = preview.statusCommunityChannelPreview
        status.add(statusLinkPreview)
      else:
        discard
  
  return (standard, status)
