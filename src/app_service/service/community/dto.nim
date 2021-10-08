{.used.}

import json, strformat

include ../../common/json_utils

type
  PermissionDto* = ref object
    access*: int

type
  ImagesDto* = ref object
    thumbnail*: string
    large*: string

type ChatDto* = ref object
  id*: string
  name*: string
  color*: string
  emoji*: string
  description*: string
  #members*: seq[ChatMember] ???? It's always null and a question why do we need it here within this context ????
  permissions*: PermissionDto
  canPost*: bool
  position*: int
  categoryId*: string

type CategoryDto* = ref object
  id*: string
  name*: string
  position*: int

type MemberDto* = ref object
  id*: string
  roles*: seq[int]

type CommunityDto* = ref object
  id*: string
  admin*: bool
  verified*: bool
  joined*: bool
  requestedAccessAt: int64
  name*: string
  description*: string
  chats*: seq[ChatDto]
  categories*: seq[CategoryDto]
  images*: ImagesDto
  permissions*: PermissionDto
  members*: seq[MemberDto]
  canRequestAccess*: bool
  canManageUsers*: bool
  canJoin*: bool
  color*: string
  requestedToJoinAt*: int64
  isMember*: bool
  muted*: bool
  
proc toPermissionDto(jsonObj: JsonNode): PermissionDto =
  result = PermissionDto()
  discard jsonObj.getProp("access", result.access)

proc toImagesDto(jsonObj: JsonNode): ImagesDto =
  result = ImagesDto()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard jsonObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard jsonObj.getProp("uri", result.thumbnail)

proc toChatDto(jsonObj: JsonNode): ChatDto =
  result = ChatDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("description", result.description)
  var permissionObj: JsonNode
  if(jsonObj.getProp("permissions", permissionObj)):
    result.permissions = toPermissionDto(permissionObj)
  discard jsonObj.getProp("canPost", result.canPost)
  discard jsonObj.getProp("position", result.position)
  discard jsonObj.getProp("categoryId", result.categoryId)

proc toCategoryDto(jsonObj: JsonNode): CategoryDto =
  result = CategoryDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("position", result.position)

proc toMemberDto(jsonObj: JsonNode, memberId: string): MemberDto =
  # Mapping this DTO is not strightforward since only keys are used for id. We 
  # handle it a bit different.
  result = MemberDto()
  result.id = memberId
  var rolesObj: JsonNode
  if(jsonObj.getProp("roles", rolesObj)):
    for roleObj in rolesObj:
      result.roles.add(roleObj.getInt)

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
      result.chats.add(toChatDto(chatObj))

  var categoriesObj: JsonNode
  if(jsonObj.getProp("categories", categoriesObj)):
    for _, categoryObj in categoriesObj:
      result.categories.add(toCategoryDto(categoryObj))

  var imagesObj: JsonNode
  if(jsonObj.getProp("images", imagesObj)):
    result.images = toImagesDto(imagesObj)

  var permissionObj: JsonNode
  if(jsonObj.getProp("permissions", permissionObj)):
    result.permissions = toPermissionDto(permissionObj)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj)):
    for memberId, memberObj in membersObj:
      result.members.add(toMemberDto(memberObj, memberId))

  discard jsonObj.getProp("canRequestAccess", result.canRequestAccess)
  discard jsonObj.getProp("canManageUsers", result.canManageUsers)
  discard jsonObj.getProp("canJoin", result.canJoin)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("requestedToJoinAt", result.requestedToJoinAt)
  discard jsonObj.getProp("isMember", result.isMember)
  discard jsonObj.getProp("muted", result.muted)
