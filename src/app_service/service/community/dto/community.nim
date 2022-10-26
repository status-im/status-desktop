{.used.}

import json, sequtils, sugar, tables

import ../../../../backend/communities
include ../../../common/json_utils

import ../../chat/dto/chat

type RequestToJoinType* {.pure.}= enum
  Pending = 1,
  Declined = 2,
  Accepted = 3

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
  our*: string #FIXME: should be bool

type CommunitySettingsDto* = object
  id*: string
  historyArchiveSupportEnabled*: bool
  categoriesMuted*: seq[string]

type CommunityAdminSettingsDto* = object
  pinMessageAllMembersEnabled*: bool

type CommunityDto* = object
  id*: string
  admin*: bool
  verified*: bool
  joined*: bool
  spectated*: bool
  requestedAccessAt: int64
  name*: string
  description*: string
  introMessage*: string
  outroMessage*: string
  chats*: seq[ChatDto]
  categories*: seq[Category]
  images*: Images
  permissions*: Permission
  members*: seq[Member]
  canRequestAccess*: bool
  canManageUsers*: bool
  canJoin*: bool
  color*: string
  tags*: string
  requestedToJoinAt*: int64
  isMember*: bool
  muted*: bool
  pendingRequestsToJoin*: seq[CommunityMembershipRequestDto]
  settings*: CommunitySettingsDto
  adminSettings*: CommunityAdminSettingsDto
  bannedMembersIds*: seq[string]
  declinedRequestsToJoin*: seq[CommunityMembershipRequestDto]
  encrypted*: bool

type CuratedCommunity* = object
    available*: bool
    communityId*: string
    community*: CommunityDto

type DiscordCategoryDto* = object
  id*: string
  name*: string

type DiscordChannelDto* = object
  id*: string
  categoryId*: string
  name*: string
  description*: string
  filePath*: string

type DiscordImportErrorCode* {.pure.}= enum
  Unknown = 0,
  Warning = 1,
  Error = 2

type DiscordImportError* = object
  code*: int
  message*: string

type DiscordImportTaskProgress* = object
  `type`*: string
  progress*: float
  errors*: seq[DiscordImportError]
  errorsCount*: int
  warningsCount*: int
  stopped*: bool
  state*: string

proc toCommunityAdminSettingsDto*(jsonObj: JsonNode): CommunityAdminSettingsDto =
  result = CommunityAdminSettingsDto()
  discard jsonObj.getProp("pinMessageAllMembersEnabled", result.pinMessageAllMembersEnabled)

proc toDiscordCategoryDto*(jsonObj: JsonNode): DiscordCategoryDto =
  result = DiscordCategoryDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)

proc toDiscordChannelDto*(jsonObj: JsonNode): DiscordChannelDto =
  result = DiscordChannelDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("categoryId", result.categoryId)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("topic", result.description)
  discard jsonObj.getProp("filePath", result.filePath)

proc toDiscordImportError*(jsonObj: JsonNode): DiscordImportError =
  result = DiscordImportError()
  discard jsonObj.getProp("code", result.code)
  discard jsonObj.getProp("message", result.message)

proc toDiscordImportTaskProgress*(jsonObj: JsonNode): DiscordImportTaskProgress =
  result = DiscordImportTaskProgress()
  result.`type` = jsonObj{"type"}.getStr()
  result.progress = jsonObj{"progress"}.getFloat()
  result.stopped = jsonObj{"stopped"}.getBool()
  result.errorsCount = jsonObj{"errorsCount"}.getInt()
  result.warningsCount = jsonObj{"warningsCount"}.getInt()
  result.state = jsonObj{"state"}.getStr()

  var importErrorsObj: JsonNode
  if(jsonObj.getProp("errors", importErrorsObj) and importErrorsObj.kind == JArray):
    for error in importErrorsObj:
      let importError = error.toDiscordImportError()
      result.errors.add(importError)

proc toCommunityDto*(jsonObj: JsonNode): CommunityDto =
  result = CommunityDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("admin", result.admin)
  discard jsonObj.getProp("verified", result.verified)
  discard jsonObj.getProp("joined", result.joined)
  discard jsonObj.getProp("spectated", result.spectated)
  discard jsonObj.getProp("requestedAccessAt", result.requestedAccessAt)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("introMessage", result.introMessage)
  discard jsonObj.getProp("outroMessage", result.outroMessage)
  discard jsonObj.getProp("encrypted", result.encrypted)

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

  var adminSettingsObj: JsonNode
  if(jsonObj.getProp("adminSettings", adminSettingsObj)):
    result.adminSettings = toCommunityAdminSettingsDto(adminSettingsObj)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj) and membersObj.kind == JObject):
    for memberId, memberObj in membersObj:
      result.members.add(toMember(memberObj, memberId))

  var tagsObj: JsonNode
  if(jsonObj.getProp("tags", tagsObj)):
    toUgly(result.tags, tagsObj)
  else:
    result.tags = "[]"

  var bannedMembersIdsObj: JsonNode
  if(jsonObj.getProp("banList", bannedMembersIdsObj) and bannedMembersIdsObj.kind == JArray):
    for bannedMemberId in bannedMembersIdsObj:
      result.bannedMembersIds.add(bannedMemberId.getStr)

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

proc toCommunitySettingsDto*(jsonObj: JsonNode): CommunitySettingsDto =
  result = CommunitySettingsDto()
  discard jsonObj.getProp("communityId", result.id)
  discard jsonObj.getProp("historyArchiveSupportEnabled", result.historyArchiveSupportEnabled)

proc parseCommunities*(response: RpcResponse[JsonNode]): seq[CommunityDto] =
  result = map(response.result.getElems(),
    proc(x: JsonNode): CommunityDto = x.toCommunityDto())

proc parseCuratedCommunities*(response: RpcResponse[JsonNode]): seq[CuratedCommunity] =
  if (response.result["communities"].kind == JObject):
    for (communityId, communityJson) in response.result["communities"].pairs():
      result.add(CuratedCommunity(
        available: true,
        communityId: communityId,
        community: communityJson.toCommunityDto()
      ))
  if (response.result["unknownCommunities"].kind == JArray):
    for communityId in response.result["unknownCommunities"].items():
      result.add(CuratedCOmmunity(
        available: false,
        communityId: communityId.getStr()
      ))
  
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
    introMessage: communityDto.introMessage,
    outroMessage: communityDto.outroMessage,
    color: communityDto.color,
    # tags: communityDto.tags, NOTE: do we need tags here?
    permissions: communityDto.permissions,
    members: communityDto.members.map(m => ChatMember(
        id: m.id,
        joined: true,
        admin: isMemberAdmin(m.roles)
      )),
    canManageUsers: communityDto.canManageUsers,
    muted: communityDto.muted,
    historyArchiveSupportEnabled: communityDto.settings.historyArchiveSupportEnabled,
    bannedMembersIds: communityDto.bannedMembersIds,
    encrypted: communityDto.encrypted,
  )

proc parseCommunitiesSettings*(response: RpcResponse[JsonNode]): seq[CommunitySettingsDto] =
  result = map(response.result.getElems(),
    proc(x: JsonNode): CommunitySettingsDto = x.toCommunitySettingsDto())

proc parseDiscordCategories*(response: RpcResponse[JsonNode]): seq[DiscordCategoryDto] =
  if (response.result["discordCategories"].kind == JArray):
    for category in response.result["discordCategories"].items():
      result.add(category.toDiscordCategoryDto())

proc parseDiscordCategories*(response: JsonNode): seq[DiscordCategoryDto] =
  if (response["discordCategories"].kind == JArray):
    for category in response["discordCategories"].items():
      result.add(category.toDiscordCategoryDto())

proc parseDiscordChannels*(response: RpcResponse[JsonNode]): seq[DiscordChannelDto] =
  if (response.result["discordChannels"].kind == JArray):
    for channel in response.result["discordChannels"].items():
      result.add(channel.toDiscordChannelDto())

proc parseDiscordChannels*(response: JsonNode): seq[DiscordChannelDto] =
  if (response["discordChannels"].kind == JArray):
    for channel in response["discordChannels"].items():
      result.add(channel.toDiscordChannelDto())
