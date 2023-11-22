{.used.}

import json

include ../../../common/json_utils

type RemovedMessageDto* = object
  chatId*: string
  messageId*: string
  deletedBy*: string

proc toRemovedMessageDto*(jsonObj: JsonNode): RemovedMessageDto =
  result = RemovedMessageDto()
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("messageId", result.messageId)
  discard jsonObj.getProp("deletedBy", result.deletedBy)
