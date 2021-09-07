{.used.}

import json

type RemovedMessage* = object
  chatId*: string
  messageId*: string

proc toRemovedMessage*(jsonRemovedMessage: JsonNode): RemovedMessage =
  result = RemovedMessage(
    chatId: jsonRemovedMessage{"chatId"}.getStr,
    messageId: jsonRemovedMessage{"messageId"}.getStr,
  )