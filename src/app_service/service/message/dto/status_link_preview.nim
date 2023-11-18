import json, chronicles
import status_contact_link_preview
import status_community_link_preview
import status_community_channel_link_preview
include ../../../common/json_utils


type StatusLinkPreview* = ref object
  url*: string
  contact*: StatusContactLinkPreview
  community*: StatusCommunityLinkPreview
  channel*: StatusCommunityChannelLinkPreview

proc toStatusLinkPreview*(jsonObj: JsonNode): StatusLinkPreview =
  result = StatusLinkPreview()
  discard jsonObj.getProp("url", result.url)

  var contact: JsonNode
  if jsonObj.getProp("contact", contact):
    result.contact = toStatusContactLinkPreview(contact)

  var community: JsonNode
  if jsonObj.getProp("community", community):
    result.community = toStatusCommunityLinkPreview(contact)

  var channel: JsonNode
  if jsonObj.getProp("channel", channel):
    result.channel = toStatusCommunityChannelLinkPreview(contact)

proc `%`*(self: StatusLinkPreview): JsonNode =
  var obj = %*{
    "url": self.url
  }
  if self.contact != nil:
    obj["contact"] = %*self.contact
  if self.community != nil:
    obj["community"] = %*self.community
  if self.channel != nil:
    obj["channel"] = %*self.channel
  return obj
