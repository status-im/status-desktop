{.used.}

import json, strformat, strutils

include ../../../common/json_utils

type ChatType* {.pure.}= enum
  Unknown = 0,
  OneToOne = 1,
  Public = 2,
  PrivateGroupChat = 3,
  Profile = 4,
  CommunityChat = 6

type ChannelGroupType* {.pure.}= enum
  Unknown = "unknown",
  Personal = "personal",
  Community = "community"

type Category* = object
  id*: string
  name*: string
  position*: int

type
  Permission* = object
    access*: int
    ensOnly*: bool

type
  Images* = object
    thumbnail*: string
    large*: string
    banner*: string

type ChatMember* = object
  id*: string
  admin*: bool
  joined*: bool
  roles*: seq[int]

type ChatDto* = object
  id*: string # ID is the id of the chat, for public chats it is the name e.g. status,
  # for one-to-one is the hex encoded public key and for group chats is a random
  # uuid appended with the hex encoded pk of the creator of the chat
  name*: string
  description*: string
  color*: string
  emoji*: string
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
  icon*: string
  muted*: bool
  communityId*: string #set if chat belongs to a community
  profile*: string
  joined*: int64 # indicates when the user joined the chat last time
  syncedTo*: int64
  syncedFrom*: int64
  canPost*: bool
  position*: int
  categoryId*: string
  highlight*: bool
  permissions*: Permission

type ChannelGroupDto* = object
  id*: string
  channelGroupType*: ChannelGroupType
  admin*: bool
  verified*: bool
  name*: string
  ensName*: string
  description*: string
  introMessage*: string
  outroMessage*: string
  chats*: seq[ChatDto]
  categories*: seq[Category]
  images*: Images
  permissions*: Permission
  members*: seq[ChatMember]
  canManageUsers*: bool
  color*: string
  muted*: bool
  historyArchiveSupportEnabled*: bool
  pinMessageAllMembersEnabled*: bool

type ClearedHistoryDto* = object
  chatId*: string
  clearedAt*: int

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
    members: {self.members},
    alias: {self.alias},
    icon: {self.icon},
    muted: {self.muted},
    communityId: {self.communityId},
    profile: {self.profile},
    joined: {self.joined},
    canPost: {self.canPost},
    syncedTo: {self.syncedTo},
    syncedFrom: {self.syncedFrom},
    categoryId: {self.categoryId},
    position: {self.position},
    highlight: {self.highlight}
    )"""

proc toClearedHistoryDto*(jsonObj: JsonNode): ClearedHistoryDto =
  result = ClearedHistoryDto()
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("clearedAt", result.clearedAt)

proc toPermission*(jsonObj: JsonNode): Permission =
  result = Permission()
  discard jsonObj.getProp("access", result.access)
  discard jsonObj.getProp("ens_only", result.ensOnly)

proc toImages*(jsonObj: JsonNode): Images =
  result = Images()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard largeObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard thumbnailObj.getProp("uri", result.thumbnail)

  var bannerObj: JsonNode
  if(jsonObj.getProp("banner", bannerObj)):
    discard bannerObj.getProp("uri", result.banner)

proc toCategory*(jsonObj: JsonNode): Category =
  result = Category()
  if (not jsonObj.getProp("category_id", result.id)):
    discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("position", result.position)

proc toChatMember*(jsonObj: JsonNode): ChatMember =
  result = ChatMember()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("admin", result.admin)
  discard jsonObj.getProp("joined", result.joined)

  var rolesObj: JsonNode
  if(jsonObj.getProp("roles", rolesObj) and rolesObj.kind == JArray):
    for role in rolesObj:
      result.roles.add(role.getInt)

proc toChatMember(jsonObj: JsonNode, memberId: string): ChatMember =
  # Mapping this DTO is not strightforward since only keys are used for id. We
  # handle it a bit different.
  result = jsonObj.toChatMember()
  result.id = memberId

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
  discard jsonObj.getProp("readMessagesAtClockValue", result.readMessagesAtClockValue)
  discard jsonObj.getProp("unviewedMessagesCount", result.unviewedMessagesCount)
  discard jsonObj.getProp("unviewedMentionsCount", result.unviewedMentionsCount)
  discard jsonObj.getProp("canPost", result.canPost)
  discard jsonObj.getProp("alias", result.alias)
  discard jsonObj.getProp("identicon", result.icon)
  discard jsonObj.getProp("muted", result.muted)
  discard jsonObj.getProp("categoryId", result.categoryId)
  if (result.categoryId == ""):
    # Communities have `categoryID` and chats have `categoryId`
    # This should be fixed in status-go, but would be a breaking change
    discard jsonObj.getProp("categoryID", result.categoryId)
  discard jsonObj.getProp("position", result.position)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("profile", result.profile)
  discard jsonObj.getProp("joined", result.joined)
  discard jsonObj.getProp("syncedTo", result.syncedTo)
  discard jsonObj.getProp("syncedFrom", result.syncedFrom)
  discard jsonObj.getProp("highlight", result.highlight)
  var permissionObj: JsonNode
  if(jsonObj.getProp("permissions", permissionObj)):
    result.permissions = toPermission(permissionObj)

  result.chatType = ChatType.Unknown
  var chatTypeInt: int
  if (jsonObj.getProp("chatType", chatTypeInt) and
    (chatTypeInt >= ord(low(ChatType)) or chatTypeInt <= ord(high(ChatType)))):
      result.chatType = ChatType(chatTypeInt)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj)):
    if(membersObj.kind == JArray):
      for memberObj in membersObj:
        result.members.add(toChatMember(memberObj))
    elif(membersObj.kind == JObject):
      for memberId, memberObj in membersObj:
        result.members.add(toChatMember(memberObj, memberId))

  # Add community ID if needed
  if (result.communityId != "" and not result.id.contains(result.communityId)):
    result.id = result.communityId & result.id

proc toChannelGroupDto*(jsonObj: JsonNode): ChannelGroupDto =
  result = ChannelGroupDto()
  discard jsonObj.getProp("admin", result.admin)
  discard jsonObj.getProp("verified", result.verified)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("introMessage", result.introMessage)
  discard jsonObj.getProp("outroMessage", result.outroMessage)

  result.channelGroupType = ChannelGroupType.Unknown
  var channelGroupTypeString: string
  if (jsonObj.getProp("channelGroupType", channelGroupTypeString)):
      result.channelGroupType = parseEnum[ChannelGroupType](channelGroupTypeString)

  var chatsObj: JsonNode
  if(jsonObj.getProp("chats", chatsObj)):
    for _, chatObj in chatsObj:
      result.chats.add(toChatDto(chatObj))

  var categoriesObj: JsonNode
  if(jsonObj.getProp("categories", categoriesObj)):
    for _, categoryObj in categoriesObj:
      result.categories.add(toCategory(categoryObj))

  var imagesObj: JsonNode
  if(jsonObj.getProp("images", imagesObj)):
    result.images = toImages(imagesObj)

  var permissionObj: JsonNode
  if(jsonObj.getProp("permissions", permissionObj)):
    result.permissions = toPermission(permissionObj)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj) and membersObj.kind == JObject):
    for memberId, memberObj in membersObj:
      result.members.add(toChatMember(memberObj, memberId))

  discard jsonObj.getProp("canManageUsers", result.canManageUsers)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("muted", result.muted)

# To parse Community chats to ChatDto, we need to add the commuity ID and type
proc toChatDto*(jsonObj: JsonNode, communityId: string): ChatDto =
  result = jsonObj.toChatDto()
  result.chatType = ChatType.CommunityChat
  result.communityId = communityId
  if communityId != "":
    result.id = communityId & result.id.replace(communityId, "") # Adding communityID prefix in case it's not available

proc isPublicChat*(chatDto: ChatDto): bool =
  return chatDto.chatType == ChatType.Public

proc isOneToOneChat*(chatDto: ChatDto): bool =
  return chatDto.chatType == ChatType.OneToOne
