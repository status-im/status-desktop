{.used.}

import json

include ../../../common/json_utils

type PinnedMessageUpdateDto* = object
  chatId*: string
  messageId*: string
  localChatId*: string # not sure what's this and do we need this at all
  pinnedBy*: string
  identicon*: string
  alias*: string
  clock*: int64
  pinned*: bool
  contentType*: int

proc toPinnedMessageUpdateDto*(jsonObj: JsonNode): PinnedMessageUpdateDto =
  result = PinnedMessageUpdateDto()
  discard jsonObj.getProp("chat_id", result.chatId)
  discard jsonObj.getProp("message_id", result.messageId)
  discard jsonObj.getProp("localChatId", result.localChatId)
  discard jsonObj.getProp("from", result.pinnedBy)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("clock", result.clock)
  discard jsonObj.getProp("pinned", result.pinned)
  discard jsonObj.getProp("contentType", result.contentType)