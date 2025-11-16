{.used.}

import json

include ../../../common/json_utils

type ReactionDto* = object
  id*: string
  clock*: int64
  chatId*: string
  localChatId*: string
  `from`*: string
  messageId*: string
  emoji*: string

proc toReactionDto*(jsonObj: JsonNode): ReactionDto =
  result = ReactionDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("localChatId", result.localChatId)
  discard jsonObj.getProp("from", result.from)
  discard jsonObj.getProp("messageId", result.messageId)
  discard jsonObj.getProp("emoji", result.emoji)

