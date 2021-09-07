{.used.}

import strformat, json, sequtils

type ChatMember* = object
  admin*: bool
  id*: string
  joined*: bool
  identicon*: string
  userName*: string
  localNickname*: string

proc toJsonNode*(self: ChatMember): JsonNode =
  result = %* {
    "id": self.id,
    "admin": self.admin,
    "joined": self.joined
  }

proc toJsonNode*(self: seq[ChatMember]): seq[JsonNode] =
  result = map(self, proc(x: ChatMember): JsonNode = x.toJsonNode)