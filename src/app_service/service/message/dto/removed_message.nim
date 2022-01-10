{.used.}

import json

include ../../../common/json_utils

type RemovedMessageDto* = object
  chatId*: string
  messageId*: string

proc toRemovedMessageDto*(jsonObj: JsonNode): RemovedMessageDto =
  result = RemovedMessageDto()
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("messageId", result.messageId)