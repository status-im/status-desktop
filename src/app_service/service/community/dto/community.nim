{.used.}

import json, sequtils, sugar

import ../../../../backend/communities
include ../../../common/json_utils

import ../../chat/dto/chat

type
  CommunityMemberRoles* {.pure.} = enum
    Unknown = 0,
    All = 1,
    ManagerUsers = 2

type Member* = object
  id*: string
  roles*: seq[int]

proc toMember*(jsonObj: JsonNode, memberId: string): Member =
  # Mapping this DTO is not strightforward since only keys are used for id. We
  # handle it a bit different.
  result = Member()
  result.id = memberId
  var rolesObj: JsonNode
  if(jsonObj.getProp("roles", rolesObj)):
    for roleObj in rolesObj:
      result.roles.add(roleObj.getInt)

type CommunityMembershipRequestDto* = object
  id*: string
  publicKey*: string
  chatId*: string
  communityId*: string
  state*: int
  our*: string

type CommunityDto* = object
  id*: string
  admin*: bool
  verified*: bool
  joined*: bool
  requestedAccessAt: int64
  name*: string
  description*: string
  chats*: seq[ChatDto]
  categories*: seq[Category]
  images*: Images
  permissions*: Permission
  members*: seq[Member]
  canRequestAccess*: bool
  canManageUsers*: bool
  canJoin*: bool
  color*: string
  requestedToJoinAt*: int64
  isMember*: bool
  muted*: bool
  pendingRequestsToJoin*: seq[CommunityMembershipRequestDto]

proc toCommunityDto*(jsonObj: JsonNode): CommunityDto =
  result = CommunityDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("admin", result.admin)
  discard jsonObj.getProp("verified", result.verified)
  discard jsonObj.getProp("joined", result.joined)
  discard jsonObj.getProp("requestedAccessAt", result.requestedAccessAt)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)

  var chatsObj: JsonNode
  if(jsonObj.getProp("chats", chatsObj)):
    for _, chatObj in chatsObj:
      result.chats.add(chatObj.toChatDto(result.id))

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
      result.members.add(toMember(memberObj, memberId))

  discard jsonObj.getProp("canRequestAccess", result.canRequestAccess)
  discard jsonObj.getProp("canManageUsers", result.canManageUsers)
  discard jsonObj.getProp("canJoin", result.canJoin)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("requestedToJoinAt", result.requestedToJoinAt)
  discard jsonObj.getProp("isMember", result.isMember)
  discard jsonObj.getProp("muted", result.muted)

proc toCommunityMembershipRequestDto*(jsonObj: JsonNode): CommunityMembershipRequestDto =
  result = CommunityMembershipRequestDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("publicKey", result.publicKey)
  discard jsonObj.getProp("chatId", result.chatId)
  discard jsonObj.getProp("state", result.state)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("our", result.our)

proc parseCommunities*(response: RpcResponse[JsonNode]): seq[CommunityDto] =
  result = map(response.result.getElems(),
    proc(x: JsonNode): CommunityDto = x.toCommunityDto())

proc contains(arrayToSearch: seq[int], searched: int): bool =
  for element in arrayToSearch:
    if element == searched:
      return true
  return false

proc toChannelGroupDto*(communityDto: CommunityDto): ChannelGroupDto =
  ChannelGroupDto(
    id: communityDto.id,
    channelGroupType: ChannelGroupType.Community,
    name: communityDto.name,
    images: communityDto.images,
    chats: communityDto.chats,
    categories: communityDto.categories,
    # Community doesn't have an ensName yet. Add this when it is added in status-go
    # ensName: communityDto.ensName,
    admin: communityDto.admin,
    verified: communityDto.verified,
    description: communityDto.description,
    color: communityDto.color,
    permissions: communityDto.permissions,
    members: communityDto.members.map(m => ChatMember(
        id: m.id,
        joined: true,
        admin: m.roles.contains(CommunityMemberRoles.ManagerUsers.int)
      )),
    canManageUsers: communityDto.canManageUsers,
    muted: communityDto.muted
  )