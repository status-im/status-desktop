{.used.}

import strformat, json, sequtils

type ChatMembershipEvent* = object
  chatId*: string
  clockValue*: int64
  fromKey*: string
  name*: string
  members*: seq[string]
  rawPayload*: string
  signature*: string 
  eventType*: int

proc toJsonNode*(self: ChatMembershipEvent): JsonNode =
  result = %* {
    "chatId": self.chatId,
    "name": self.name,
    "clockValue": self.clockValue,
    "from": self.fromKey,
    "members": self.members,
    "rawPayload": self.rawPayload,
    "signature": self.signature,
    "type": self.eventType
  }

proc toJsonNode*(self: seq[ChatMembershipEvent]): seq[JsonNode] =
  result = map(self, proc(x: ChatMembershipEvent): JsonNode = x.toJsonNode)