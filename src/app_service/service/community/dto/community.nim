{.used.}

import json

include ../../../common/json_utils

type
  Permission* = ref object
    access*: int

type
  Images* = ref object
    thumbnail*: string
    large*: string

type Chat* = ref object
  id*: string
  name*: string
  color*: string
  emoji*: string
  description*: string
  #members*: seq[ChatMember] ???? It's always null and a question is why do we need it here within this context ????
  permissions*: Permission
  canPost*: bool
  position*: int
  categoryId*: string

type Category* = ref object
  id*: string
  name*: string
  position*: int

type Member* = ref object
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
  chats*: seq[Chat]
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
  
proc toPermission(jsonObj: JsonNode): Permission =
  result = Permission()
  discard jsonObj.getProp("access", result.access)

proc toImages(jsonObj: JsonNode): Images =
  result = Images()

  var largeObj: JsonNode
  if(jsonObj.getProp("large", largeObj)):
    discard largeObj.getProp("uri", result.large)

  var thumbnailObj: JsonNode
  if(jsonObj.getProp("thumbnail", thumbnailObj)):
    discard thumbnailObj.getProp("uri", result.thumbnail)

proc toChat(jsonObj: JsonNode): Chat =
  result = Chat()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("description", result.description)
  var permissionObj: JsonNode
  if(jsonObj.getProp("permissions", permissionObj)):
    result.permissions = toPermission(permissionObj)
  discard jsonObj.getProp("canPost", result.canPost)
  discard jsonObj.getProp("position", result.position)
  discard jsonObj.getProp("categoryID", result.categoryId)

proc toCategory(jsonObj: JsonNode): Category =
  result = Category()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("position", result.position)

proc toMember(jsonObj: JsonNode, memberId: string): Member =
  # Mapping this DTO is not strightforward since only keys are used for id. We 
  # handle it a bit different.
  result = Member()
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
      result.chats.add(toChat(chatObj))

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
  if(jsonObj.getProp("members", membersObj)):
    for memberId, memberObj in membersObj:
      result.members.add(toMember(memberObj, memberId))

  discard jsonObj.getProp("canRequestAccess", result.canRequestAccess)
  discard jsonObj.getProp("canManageUsers", result.canManageUsers)
  discard jsonObj.getProp("canJoin", result.canJoin)
  discard jsonObj.getProp("color", result.color)
  discard jsonObj.getProp("requestedToJoinAt", result.requestedToJoinAt)
  discard jsonObj.getProp("isMember", result.isMember)
  discard jsonObj.getProp("muted", result.muted)
