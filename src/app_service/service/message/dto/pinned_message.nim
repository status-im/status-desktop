{.used.}

import json

import message

include ../../../common/json_utils

type PinnedMessageDto* = object
  pinnedAt*: int64
  pinnedBy*: string
  message*: MessageDto

proc toPinnedMessageDto*(jsonObj: JsonNode): PinnedMessageDto =
  result = PinnedMessageDto()
  discard jsonObj.getProp("pinnedAt", result.pinnedAt)
  discard jsonObj.getProp("pinnedBy", result.pinnedBy)

  var messageObj: JsonNode
  if (jsonObj.getProp("message", messageObj)):
    result.message = toMessageDto(messageObj)
