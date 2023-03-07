{.used.}

import json, sequtils, sugar, tables, strutils, json_serialization

import ../../../../backend/communities
include ../../../common/json_utils
import ../../../common/types
import ../../../common/conversion

import ../../chat/dto/chat

type RequestToJoinType* {.pure.}= enum
  Pending = 1,
  Declined = 2,
  Accepted = 3,
  Canceled = 4

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

type TokenPermissionType* {.pure.}= enum
  Unknown = 0,
  BecomeAdmin = 1,
  BecomeMember = 2

type TokenType* {.pure.}= enum
  Unknown = 0,
  ERC20 = 1,
  ERC721 = 2,
  ENS = 3 # ENS is also ERC721 but we want to distinguish without heuristics

type TokenCriteriaDto* = object
  contractAddresses* {.serializedFieldName("contract_addresses").}: Table[int, string]
  `type`* {.serializedFieldName("type").}: TokenType
  symbol* {.serializedFieldName("symbol").}: string
  name* {.serializedFieldName("name").}: string
  amount* {.serializedFieldName("amount").}: string
  decimals* {.serializedFieldName("decimals").}: int
  tokenIds* {.serializedFieldName("tokenIds").}: seq[string]
  ensPattern* {.serializedFieldName("ens_pattern").}: string

type CommunityTokenPermissionDto* = object
  id*: string
  `type`*: TokenPermissionType
  tokenCriteria*: seq[TokenCriteriaDto]
  chatIds*: seq[string]
  isPrivate*: bool

type CommunityTokensMetadataDto* = object
  addresses*: Table[int, string]
  description*: string
  image*: string
  symbol*: string
  name*: string
  tokenType*: TokenType

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
  members*: seq[ChatMember]
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
  canceledRequestsToJoin*: seq[CommunityMembershipRequestDto]  
  tokenPermissions*: Table[string, CommunityTokenPermissionDto]
  communityTokensMetadata*: seq[CommunityTokensMetadataDto]

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
  Unknown = 1,
  Warning = 2,
  Error = 3

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

proc toCommunityTokenAdresses*(jsonObj: JsonNode): Table[int, string] =
  for i in jsonObj.keys():
    result[parseInt(i)] = jsonObj[i].getStr()

proc toCommunityTokensMetadataDto*(jsonObj: JsonNode): CommunityTokensMetadataDto =
  result = CommunityTokensMetadataDto()
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("image", result.image)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("name", result.name)
  var tokenTypeInt: int
  discard jsonObj.getProp("tokenType", tokenTypeInt)
  result.tokenType = intToEnum(tokenTypeInt, TokenType.ERC721)
  var addressesObj: JsonNode
  discard jsonObj.getProp("contract_addresses", addressesObj)
  result.addresses = toCommunityTokenAdresses(addressesObj)

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

proc toTokenCriteriaDto*(jsonObj: JsonNode): TokenCriteriaDto =
  result = TokenCriteriaDto()
  discard jsonObj.getProp("amount", result.amount)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("ens_pattern", result.ensPattern)

  var typeInt: int
  discard jsonObj.getProp("type", typeInt)
  if (typeInt >= ord(low(TokenType)) and typeInt <= ord(high(TokenType))):
      result.`type` = TokenType(typeInt)

  var contractAddressesObj: JsonNode
  if(jsonObj.getProp("contractAddresses", contractAddressesObj) and contractAddressesObj.kind == JObject):
    result.contractAddresses = initTable[int, string]()
    for chainId, contractAddress in contractAddressesObj:
      result.contractAddresses[parseInt(chainId)] = contractAddress.getStr

  var tokenIdsObj: JsonNode
  if(jsonObj.getProp("tokenIds", tokenIdsObj) and tokenIdsObj.kind == JArray):
    for tokenId in tokenIdsObj:
      result.tokenIds.add(tokenId.getStr)

  # When `toTokenCriteriaDto` is called with data coming from
  # the front-end, there's a key field we have to account for
  if jsonObj.hasKey("key"):
    if result.`type` == TokenType.ENS:
      discard jsonObj.getProp("key", result.ensPattern)
    else:
      discard jsonObj.getProp("key", result.symbol)

proc toCommunityTokenPermissionDto*(jsonObj: JsonNode): CommunityTokenPermissionDto =
  result = CommunityTokenPermissionDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("isPrivate", result.isPrivate)
  var tokenPermissionTypeInt: int
  discard jsonObj.getProp("type", tokenPermissionTypeInt)
  if (tokenPermissionTypeInt >= ord(low(TokenPermissionType)) or tokenPermissionTypeInt <= ord(high(TokenPermissionType))):
      result.`type` = TokenPermissionType(tokenPermissionTypeInt)

  var tokenCriteriaObj: JsonNode
  if(jsonObj.getProp("token_criteria", tokenCriteriaObj)):
    for tokenCriteria in tokenCriteriaObj:
      result.tokenCriteria.add(tokenCriteria.toTokenCriteriaDto)

  var chatIdsObj: JsonNode
  if(jsonObj.getProp("chatIds", chatIdsObj) and chatIdsObj.kind == JArray):
    for chatId in chatIdsObj:
      result.chatIds.add(chatId.getStr)

  # When `toTokenPermissionDto` is called with data coming from
  # the front-end, there's a key field we have to account for
  if jsonObj.hasKey("key"):
    discard jsonObj.getProp("key", result.id)

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
  discard jsonObj.getProp("isMember", result.isMember)

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

  var tokenPermissionsObj: JsonNode
  if(jsonObj.getProp("tokenPermissions", tokenPermissionsObj) and tokenPermissionsObj.kind == JObject):
    result.tokenPermissions = initTable[string, CommunityTokenPermissionDto]()
    for tokenPermissionId, tokenPermission in tokenPermissionsObj:
      result.tokenPermissions[tokenPermissionId] = toCommunityTokenPermissionDto(tokenPermission)

  var adminSettingsObj: JsonNode
  if(jsonObj.getProp("adminSettings", adminSettingsObj)):
    result.adminSettings = toCommunityAdminSettingsDto(adminSettingsObj)

  var membersObj: JsonNode
  if(jsonObj.getProp("members", membersObj) and membersObj.kind == JObject):
    for memberId, memberObj in membersObj:
      # Do not display members list until the user became a community member
      result.members.add(toChannelMember(memberObj, memberId, joined = result.isMember))

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
  discard jsonObj.getProp("muted", result.muted)

  var communityTokensMetadataObj: JsonNode
  if(jsonObj.getProp("communityTokensMetadata", communityTokensMetadataObj) and communityTokensMetadataObj.kind == JArray):
    for tokenObj in communityTokensMetadataObj:
      result.communityTokensMetadata.add(tokenObj.toCommunityTokensMetadataDto())

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
      result.add(CuratedCommunity(
        available: false,
        communityId: communityId.getStr()
      ))

proc parseCuratedCommunities*(response: JsonNode): seq[CuratedCommunity] =
  if (response["communities"].kind == JObject):
    for (communityId, communityJson) in response["communities"].pairs():
      result.add(CuratedCommunity(
        available: true,
        communityId: communityId,
        community: communityJson.toCommunityDto()
      ))
  if (response["unknownCommunities"].kind == JArray):
    for communityId in response["unknownCommunities"].items():
      result.add(CuratedCommunity(
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
        admin: isMemberAdmin(m.roles),
        roles: m.roles
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
