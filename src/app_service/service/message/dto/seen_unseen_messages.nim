import json

include ../../../common/json_utils

type SeenUnseenMessagesDto* = object
  chatId*: string
  count*: int
  countWithMentions*: int
  seen*: bool

proc toSeenUnseenMessagesDto*(jsonObj: JsonNode): SeenUnseenMessagesDto =
  result = SeenUnseenMessagesDto()
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("count", result.count)
  discard jsonObj.getProp("countWithMentions", result.countWithMentions)
  discard jsonObj.getProp("seen", result.seen)
