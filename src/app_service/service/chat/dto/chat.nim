{.used.}

import json, strformat

include ../../../common/json_utils

type ChatType* {.pure.}= enum
  Unknown = 0,
  OneToOne = 1, 
  Public = 2,
  PrivateGroupChat = 3,
  Profile = 4,
  Timeline = 5
  CommunityChat = 6

type ChatMember* = object
  id*: string
  admin*: bool
  joined*: bool

type ChatDto* = object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, 
  # for one-to-one is the hex encoded public key and for group chats is a random
  # uuid appended with the hex encoded pk of the creator of the chat
  name*: string
  description*: string
  color*: string
  emoji*: string # not sure why do we receive this at all?
  active*: bool # indicates whether the chat has been soft deleted
  chatType*: ChatType
  timestamp*: int64 # indicates the last time this chat has received/sent a message
  lastClockValue*: int64 # indicates the last clock value to be used when sending messages
  deletedAtClockValue*: int64 # indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
  readMessagesAtClockValue*: int64
  unviewedMessagesCount*: int
  unviewedMentionsCount*: int
  #lastMessage*: Message ???? It's a question why do we need it here within this context ????
  members*: seq[ChatMember]
  #membershipUpdateEvents*: seq[ChatMembershipEvent]  ???? It's always null and a question why do we need it here within this context ????
  alias*: string
  identicon*: string
  muted*: bool
  communityId*: string #set if chat belongs to a community
  profile*: string
  joined*: int64 # indicates when the user joined the chat last time
  syncedTo*: int64
  syncedFrom*: int64
  canPost*: bool
  position*: int
  categoryId*: string

proc `$`*(self: ChatDto): string =
  result = fmt"""ChatDto(
    id: {self.id}, 
    name: {self.name}, 
    description: {self.description}, 
    color: {self.color}, 
    emoji: {self.emoji}, 
    active: {self.active}, 
    chatType: {self.chatType}, 
    timestamp: {self.timestamp}, 
    lastClockValue: {self.lastClockValue}, 
    deletedAtClockValue: {self.deletedAtClockValue}, 
    readMessagesAtClockValue: {self.readMessagesAtClockValue}, 
    unviewedMessagesCount: {self.unviewedMessagesCount}, 
    unviewedMentionsCount: {self.unviewedMentionsCount}, 
    alias: {self.alias}, 
    identicon: {self.identicon}, 
    muted: {self.muted}, 
    communityId: {self.communityId}, 
    profile: {self.profile}, 
    joined: {self.joined}, 
    syncedTo: {self.syncedTo}, 
    syncedFrom: {self.syncedFrom}
    )"""

proc toChatMember(jsonObj: JsonNode): ChatMember =
  result = ChatMember()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("admin", result.admin)
  discard jsonObj.getProp("joined", result.joined)

proc toChatDto*(jsonObj: JsonNode): ChatDto =
  result = ChatDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("active", result.active)
  discard jsonObj.getProp("timestamp", result.timestamp)
  discard jsonObj.getProp("lastClockValue", result.lastClockValue)
  discard jsonObj.getProp("deletedAtClockValue", result.deletedAtClockValue)
  discard jsonObj.getProp("ReadMessagesAtClockValue", result.readMessagesAtClockValue)
  discard jsonObj.getProp("unviewedMessagesCount", result.unviewedMessagesCount)
  discard jsonObj.getProp("unviewedMentionsCount", result.unviewedMentionsCount)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.identicon)
  discard jsonObj.getProp("muted", result.muted)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("profile", result.profile)
  discard jsonObj.getProp("joined", result.joined)
  discard jsonObj.getProp("syncedTo", result.syncedTo)
  discard jsonObj.getProp("syncedFrom", result.syncedFrom)

  result.chatType = ChatType.Unknown
  var chatTypeInt: int
  if (jsonObj.getProp("chatType", chatTypeInt) and
    (chatTypeInt >= ord(low(ChatType)) or chatTypeInt <= ord(high(ChatType)))): 
      result.chatType = ChatType(chatTypeInt)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj) and membersObj.kind == JArray):
    for memberObj in membersObj:
      result.members.add(toChatMember(memberObj))