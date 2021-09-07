{.used.}

import strutils, random, strformat, json

import ../libstatus/accounts as status_accounts
import message

include chat_member
include chat_membership_event

type ChatType* {.pure.}= enum
  Unknown = 0,
  OneToOne = 1, 
  Public = 2,
  PrivateGroupChat = 3,
  Profile = 4,
  Timeline = 5
  CommunityChat = 6

proc isOneToOne*(self: ChatType): bool = self == ChatType.OneToOne
proc isTimeline*(self: ChatType): bool = self == ChatType.Timeline

type Chat* = ref object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status, for one-to-one is the hex encoded public key and for group chats is a random uuid appended with the hex encoded pk of the creator of the chat
  communityId*: string
  private*: bool
  categoryId*: string
  name*: string
  description*: string
  color*: string
  identicon*: string
  isActive*: bool # indicates whether the chat has been soft deleted
  chatType*: ChatType
  timestamp*: int64 # indicates the last time this chat has received/sent a message
  joined*: int64 # indicates when the user joined the chat last time
  lastClockValue*: int64 # indicates the last clock value to be used when sending messages
  deletedAtClockValue*: int64 # indicates the clock value at time of deletion, messages with lower clock value of this should be discarded
  unviewedMessagesCount*: int
  unviewedMentionsCount*: int
  lastMessage*: Message
  members*: seq[ChatMember]
  membershipUpdateEvents*: seq[ChatMembershipEvent]
  mentionsCount*: int  # Using this is not a good approach, we should instead use unviewedMentionsCount and refer to it always.
  muted*: bool
  canPost*: bool
  ensName*: string
  position*: int

proc `$`*(self: Chat): string =
  result = fmt"Chat(id:{self.id}, name:{self.name}, active:{self.isActive}, type:{self.chatType})"

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
    "name": (if self.ensName != "": self.ensName else: self.name),
    "timestamp": self.timestamp,
    "unviewedMessagesCount": self.unviewedMessagesCount,
    "joined": self.joined,
    "position": self.position
  }

proc toChatMember*(jsonMember: JsonNode): ChatMember =
  let pubkey = jsonMember["id"].getStr

  result = ChatMember(
    admin: jsonMember["admin"].getBool,
    id: pubkey,
    joined: jsonMember["joined"].getBool,
    identicon: generateIdenticon(pubkey),
    userName: generateAlias(pubkey)
  )

proc toChatMembershipEvent*(jsonMembership: JsonNode): ChatMembershipEvent =
  result = ChatMembershipEvent(
    chatId: jsonMembership["chatId"].getStr,
    clockValue: jsonMembership["clockValue"].getBiggestInt,
    fromKey: jsonMembership["from"].getStr,
    rawPayload: jsonMembership["rawPayload"].getStr,
    signature: jsonMembership["signature"].getStr,
    eventType: jsonMembership["type"].getInt,
    name: jsonMembership{"name"}.getStr,
    members: @[]
  )
  if jsonMembership{"members"} != nil:
    for member in jsonMembership["members"]:
      result.members.add(member.getStr)

proc toChat*(jsonChat: JsonNode): Chat =

  let chatTypeInt = jsonChat{"chatType"}.getInt
  let chatType: ChatType = if chatTypeInt >= ord(low(ChatType)) or chatTypeInt <= ord(high(ChatType)): ChatType(chatTypeInt) else: ChatType.Unknown

  result = Chat(
    id: jsonChat{"id"}.getStr,
    communityId: jsonChat{"communityId"}.getStr,
    name: jsonChat{"name"}.getStr,
    description: jsonChat{"description"}.getStr,
    identicon: "",
    color: jsonChat{"color"}.getStr,
    isActive: jsonChat{"active"}.getBool,
    chatType: chatType,
    timestamp: jsonChat{"timestamp"}.getBiggestInt,
    lastClockValue: jsonChat{"lastClockValue"}.getBiggestInt,
    deletedAtClockValue: jsonChat{"deletedAtClockValue"}.getBiggestInt, 
    unviewedMessagesCount: jsonChat{"unviewedMessagesCount"}.getInt,
    unviewedMentionsCount: jsonChat{"unviewedMentionsCount"}.getInt,
    mentionsCount: 0,
    muted: false,
    ensName: "",
    joined: 0,
    private: jsonChat{"private"}.getBool
  )

  if jsonChat.hasKey("muted") and jsonChat["muted"].kind != JNull: 
    result.muted = jsonChat["muted"].getBool

  if jsonChat["lastMessage"].kind != JNull: 
    result.lastMessage = jsonChat{"lastMessage"}.toMessage()

  if jsonChat.hasKey("joined") and jsonChat["joined"].kind != JNull:
    result.joined = jsonChat{"joined"}.getInt
  
  if result.chatType == ChatType.OneToOne:
    result.identicon = generateIdenticon(result.id)
    if result.name.endsWith(".eth"):
      result.ensName = result.name
    if result.name == "":
      result.name = generateAlias(result.id)

  if jsonChat["members"].kind != JNull:
    result.members = @[]
    for jsonMember in jsonChat["members"]:
      result.members.add(jsonMember.toChatMember)

  if jsonChat["membershipUpdateEvents"].kind != JNull:
    result.membershipUpdateEvents = @[]
    for jsonMember in jsonChat["membershipUpdateEvents"]:
      result.membershipUpdateEvents.add(jsonMember.toChatMembershipEvent)

const channelColors* = ["#fa6565", "#7cda00", "#887af9", "#51d0f0", "#FE8F59", "#d37ef4"]

proc newChat*(id: string, chatType: ChatType): Chat =
  randomize()
  
  result = Chat(
    id: id,
    color: channelColors[rand(channelColors.len - 1)],
    isActive: true,
    chatType: chatType,
    timestamp: 0,
    lastClockValue: 0,
    deletedAtClockValue: 0, 
    unviewedMessagesCount: 0,
    mentionsCount: 0,
    members: @[]
  )

  if chatType == ChatType.OneToOne:
    result.identicon = generateIdenticon(id)
    result.name = generateAlias(id)
  else:
    result.name = id