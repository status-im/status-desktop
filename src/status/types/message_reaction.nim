{.used.}

import json

type Reaction* = object
  id*: string
  chatId*: string
  fromAccount*: string
  messageId*: string
  emojiId*: int
  retracted*: bool

proc toReaction*(jsonReaction: JsonNode): Reaction =
  result = Reaction(
      id: jsonReaction{"id"}.getStr,
      chatId: jsonReaction{"chatId"}.getStr,
      fromAccount: jsonReaction{"from"}.getStr,
      messageId: jsonReaction{"messageId"}.getStr,
      emojiId: jsonReaction{"emojiId"}.getInt,
      retracted: jsonReaction{"retracted"}.getBool
    )