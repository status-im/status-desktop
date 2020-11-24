import strformat, json, sequtils
from message import Message

type ChatType* {.pure.}= enum
  Unknown = 0,
  OneToOne = 1, 
  Public = 2,
  PrivateGroupChat = 3
  CommunityChat = 6

proc isOneToOne*(self: ChatType): bool = self == ChatType.OneToOne

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

type Chat* = ref object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  name*: string
  color*: string
  identicon*: string
  isActive*: bool # indicates whether the chat has been soft deleted
  chatType*: ChatType
  timestamp*: int64 # indicates the last time this chat has received/sent a message
  lastClockValue*: int64 # indicates the last clock value to be used when sending messages
  deletedAtClockValue*: int64 # indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
  unviewedMessagesCount*: int
  lastMessage*: Message
  members*: seq[ChatMember]
  membershipUpdateEvents*: seq[ChatMembershipEvent]
  hasMentions*: bool
  muted*: bool

type CommunityChat* = ref object
  id*: string
  name*: string
  description*: string
  access*: int

type CommunityAccessLevel* = enum
    unknown = 0
    public = 1
    invitationOnly = 2
    onRequest = 3

type Community* = object
  id*: string
  name*: string
  description*: string
  chats*: seq[CommunityChat]
  # members: seq[] # TODO find what goes in there
  # color*: string
  access*: int
  admin*: bool
  joined*: bool
  verified*: bool

proc `$`*(self: Chat): string =
  result = fmt"Chat(id:{self.id}, name:{self.name}, active:{self.isActive}, type:{self.chatType})"

proc `$`*(self: Community): string =
  result = fmt"Community(id:{self.id}, name:{self.name}, description:{self.description}"

proc toJsonNode*(self: Chat): JsonNode =
  result = %* {
    "active": self.isActive,
    "chatType": self.chatType.int,
    "color": self.color,
    "deletedAtClockValue": self.deletedAtClockValue,
    "id": self.id,
    "lastClockValue": self.lastClockValue,
    "lastMessage": nil,
    "members": self.members.toJsonNode,
    "membershipUpdateEvents": self.membershipUpdateEvents.toJsonNode,
    "name": self.name,
    "timestamp": self.timestamp,
    "unviewedMessagesCount": self.unviewedMessagesCount
  }

proc findIndexById*(self: seq[Chat], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc isMember*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey and member.joined: return true
  return false

proc contains*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey: return true
  return false

proc isAdmin*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey and member.joined and member.admin: return true
  return false
