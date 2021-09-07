{.used.}

import json, strformat, tables
import chat, status_update, identity_image

include community_category
include community_membership_request

type Community* = object
  id*: string
  name*: string
  lastChannelSeen*: string
  description*: string
  chats*: seq[Chat]
  categories*: seq[CommunityCategory]
  members*: seq[string]
  access*: int
  unviewedMessagesCount*: int
  unviewedMentionsCount*: int
  admin*: bool
  joined*: bool
  verified*: bool
  ensOnly*: bool
  canRequestAccess*: bool
  canManageUsers*: bool
  canJoin*: bool
  isMember*: bool
  muted*: bool
  communityImage*: IdentityImage
  membershipRequests*: seq[CommunityMembershipRequest]
  communityColor*: string
  memberStatus*: OrderedTable[string, StatusUpdate]

proc `$`*(self: Community): string =
  result = fmt"Community(id:{self.id}, name:{self.name}, description:{self.description}"

proc toCommunity*(jsonCommunity: JsonNode): Community =
  result = Community(
    id: jsonCommunity{"id"}.getStr,
    name: jsonCommunity{"name"}.getStr,
    description: jsonCommunity{"description"}.getStr,
    access: jsonCommunity{"permissions"}{"access"}.getInt,
    admin: jsonCommunity{"admin"}.getBool,
    joined: jsonCommunity{"joined"}.getBool,
    verified: jsonCommunity{"verified"}.getBool,
    ensOnly: jsonCommunity{"permissions"}{"ens_only"}.getBool,
    canRequestAccess: jsonCommunity{"canRequestAccess"}.getBool,
    canManageUsers: jsonCommunity{"canManageUsers"}.getBool,
    canJoin: jsonCommunity{"canJoin"}.getBool,
    isMember: jsonCommunity{"isMember"}.getBool,
    muted: jsonCommunity{"muted"}.getBool,
    chats: newSeq[Chat](),
    members: newSeq[string](),
    communityColor: jsonCommunity{"color"}.getStr,
    communityImage: IdentityImage()
  )
  
  result.memberStatus = initOrderedTable[string, StatusUpdate]()

  if jsonCommunity.hasKey("images") and jsonCommunity["images"].kind != JNull:
    if jsonCommunity["images"].hasKey("thumbnail"):
      result.communityImage.thumbnail = jsonCommunity["images"]["thumbnail"]["uri"].str
    if jsonCommunity["images"].hasKey("large"):
      result.communityImage.large = jsonCommunity["images"]["large"]["uri"].str

  if jsonCommunity.hasKey("chats") and jsonCommunity["chats"].kind != JNull:
    for chatId, chat in jsonCommunity{"chats"}:
      result.chats.add(Chat(
        id: result.id & chatId,
        categoryId: chat{"categoryID"}.getStr(),
        communityId: result.id,
        name: chat{"name"}.getStr,
        description: chat{"description"}.getStr,
        canPost: chat{"canPost"}.getBool,
        chatType: ChatType.CommunityChat,
        private: chat{"permissions"}{"private"}.getBool,
        position: chat{"position"}.getInt
      ))

  if jsonCommunity.hasKey("categories") and jsonCommunity["categories"].kind != JNull:
    for catId, cat in jsonCommunity{"categories"}:
      result.categories.add(CommunityCategory(
        id: catId,
        name: cat{"name"}.getStr,
        position: cat{"position"}.getInt
      ))

  if jsonCommunity.hasKey("members") and jsonCommunity["members"].kind != JNull:
    # memberInfo is empty for now
    for memberPubKey, memeberInfo in jsonCommunity{"members"}:
      result.members.add(memberPubKey)