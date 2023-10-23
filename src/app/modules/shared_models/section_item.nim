import strformat, stint
import ./member_model, ./member_item
import ../main/communities/models/[pending_request_item, pending_request_model]
import ../main/communities/tokens/models/token_model as community_tokens_model
import ../main/communities/tokens/models/token_item

import ../../global/global_singleton

import ../../../app_service/common/types
import ../../../app_service/service/community_tokens/community_collectible_owner

type
  SectionType* {.pure.} = enum
    LoadingSection = -1
    Chat = 0
    Community,
    Wallet,
    Browser,
    ProfileSettings,
    NodeManagement,
    CommunitiesPortal

type
  SectionItem* = object
    sectionType: SectionType
    id: string
    name: string
    memberRole: MemberRole
    isControlNode: bool
    description: string
    introMessage: string
    outroMessage: string
    image: string
    bannerImageData: string
    icon: string
    color: string
    tags: string
    hasNotification: bool
    notificationsCount: int
    active: bool
    enabled: bool
    isMember: bool
    joined: bool
    canJoin: bool
    spectated: bool
    canManageUsers: bool
    canRequestAccess: bool
    access: int
    ensOnly: bool
    muted: bool
    membersModel: member_model.Model
    pendingRequestsToJoinModel: PendingRequestModel
    historyArchiveSupportEnabled: bool
    pinMessageAllMembersEnabled: bool
    bannedMembersModel: member_model.Model
    pendingMemberRequestsModel*: member_model.Model
    declinedMemberRequestsModel: member_model.Model
    encrypted: bool
    communityTokensModel: community_tokens_model.TokenModel
    pubsubTopic: string
    pubsubTopicKey: string
    shardIndex: int
    isPendingOwnershipRequest: bool

proc initItem*(
    id: string,
    sectionType: SectionType,
    name: string,
    memberRole = MemberRole.None,
    isControlNode = false,
    description = "",
    introMessage = "",
    outroMessage = "",
    image = "",
    bannerImageData = "",
    icon = "",
    color = "",
    tags = "",
    hasNotification = false,
    notificationsCount: int = 0,
    active = false,
    enabled = true,
    joined = false,
    canJoin = false,
    spectated = false,
    canManageUsers = false,
    canRequestAccess = false,
    isMember = false,
    access: int = 0,
    ensOnly = false,
    muted = false,
    members: seq[MemberItem] = @[],
    pendingRequestsToJoin: seq[PendingRequestItem] = @[],
    historyArchiveSupportEnabled = false,
    pinMessageAllMembersEnabled = false,
    bannedMembers: seq[MemberItem] = @[],
    pendingMemberRequests: seq[MemberItem] = @[],
    declinedMemberRequests: seq[MemberItem] = @[],
    encrypted: bool = false,
    communityTokens: seq[TokenItem] = @[],
    pubsubTopic = "",
    pubsubTopicKey = "",
    shardIndex = -1,
    isPendingOwnershipRequest: bool = false
    ): SectionItem =
  result.id = id
  result.sectionType = sectionType
  result.name = name
  result.memberRole = memberRole
  result.isControlNode = isControlNode
  result.description = description
  result.introMessage = introMessage
  result.outroMessage = outroMessage
  result.image = image
  result.bannerImageData = bannerImageData
  result.icon = icon
  result.color = color
  result.tags = tags
  result.hasNotification = hasNotification
  result.notificationsCount = notificationsCount
  result.active = active
  result.enabled = enabled
  result.joined = joined
  result.canJoin = canJoin
  result.spectated = spectated
  result.canManageUsers = canManageUsers
  result.canRequestAccess = canRequestAccess
  result.isMember = isMember
  result.access = access
  result.ensOnly = ensOnly
  result.muted = muted
  result.membersModel = newModel()
  result.membersModel.setItems(members)
  result.pendingRequestsToJoinModel = newPendingRequestModel()
  result.pendingRequestsToJoinModel.setItems(pendingRequestsToJoin)
  result.historyArchiveSupportEnabled = historyArchiveSupportEnabled
  result.pinMessageAllMembersEnabled = pinMessageAllMembersEnabled
  result.bannedMembersModel = newModel()
  result.bannedMembersModel.setItems(bannedMembers)
  result.pendingMemberRequestsModel = newModel()
  result.pendingMemberRequestsModel.setItems(pendingMemberRequests)
  result.declinedMemberRequestsModel = newModel()
  result.declinedMemberRequestsModel.setItems(declinedMemberRequests)
  result.encrypted = encrypted
  result.communityTokensModel = newTokenModel()
  result.communityTokensModel.setItems(communityTokens)
  result.pubsubTopic = pubsubTopic
  result.pubsubTopicKey = pubsubTopicKey
  result.shardIndex = shardIndex
  result.isPendingOwnershipRequest = isPendingOwnershipRequest

proc isEmpty*(self: SectionItem): bool =
  return self.id.len == 0

proc `$`*(self: SectionItem): string =
  result = fmt"""SectionItem(
    id: {self.id},
    sectionType: {self.sectionType.int},
    name: {self.name},
    memberRole: {self.memberRole},
    isControlNode: {self.isControlNode},
    description: {self.description},
    introMessage: {self.introMessage},
    outroMessage: {self.outroMessage},
    image: {self.image},
    bannerImageData: {self.bannerImageData},
    icon: {self.icon},
    color: {self.color},
    tags: {self.tags},
    hasNotification: {self.hasNotification},
    notificationsCount:{self.notificationsCount},
    active:{self.active},
    enabled:{self.enabled},
    joined:{self.joined},
    canJoin:{self.canJoin},
    spectated:{self.spectated},
    canManageUsers:{self.canManageUsers},
    canRequestAccess:{self.canRequestAccess},
    isMember:{self.isMember},
    access:{self.access},
    ensOnly:{self.ensOnly},
    muted:{self.muted},
    members:{self.membersModel},
    historyArchiveSupportEnabled:{self.historyArchiveSupportEnabled},
    pinMessageAllMembersEnabled:{self.pinMessageAllMembersEnabled},
    bannedMembers:{self.bannedMembersModel},
    pendingMemberRequests:{self.pendingMemberRequestsModel},
    declinedMemberRequests:{self.declinedMemberRequestsModel},
    encrypted:{self.encrypted},
    communityTokensModel:{self.communityTokensModel},
    isPendingOwnershipRequest:{self.isPendingOwnershipRequest}
    ]"""

proc id*(self: SectionItem): string {.inline.} =
  self.id

proc sectionType*(self: SectionItem): SectionType {.inline.} =
  self.sectionType

proc name*(self: SectionItem): string {.inline.} =
  self.name

proc memberRole*(self: SectionItem): MemberRole {.inline.} =
  self.memberRole

proc `memberRole=`*(self: var SectionItem, value: MemberRole) {.inline.} =
  self.memberRole = value

proc isControlNode*(self: SectionItem): bool {.inline.} =
  self.isControlNode

proc description*(self: SectionItem): string {.inline.} =
  self.description

proc introMessage*(self: SectionItem): string {.inline.} =
  self.introMessage

proc outroMessage*(self: SectionItem): string {.inline.} =
  self.outroMessage

proc image*(self: SectionItem): string {.inline.} =
  self.image

proc bannerImageData*(self: SectionItem): string {.inline.} =
  self.bannerImageData

proc icon*(self: SectionItem): string {.inline.} =
  self.icon

proc color*(self: SectionItem): string {.inline.} =
  self.color

proc tags*(self: SectionItem): string {.inline.} =
  self.tags

proc hasNotification*(self: SectionItem): bool {.inline.} =
  self.hasNotification

proc `hasNotification=`*(self: var SectionItem, value: bool) {.inline.} =
  self.hasNotification = value

proc setHasNotification*(self: var SectionItem, value: bool) {.inline.} =
  self.hasNotification = value

proc notificationsCount*(self: SectionItem): int {.inline.} =
  self.notificationsCount

proc setNotificationsCount*(self: var SectionItem, value: int) {.inline.} =
  self.notificationsCount = value

proc `notificationsCount=`*(self: var SectionItem, value: int) {.inline.} =
  self.notificationsCount = value

proc active*(self: SectionItem): bool {.inline.} =
  self.active

proc `active=`*(self: var SectionItem, value: bool) {.inline.} =
  self.active = value

proc enabled*(self: SectionItem): bool {.inline.} =
  self.enabled

proc `enabled=`*(self: var SectionItem, value: bool) {.inline.} =
  self.enabled = value

proc joined*(self: SectionItem): bool {.inline.} =
  self.joined

proc canJoin*(self: SectionItem): bool {.inline.} =
  self.canJoin

proc spectated*(self: SectionItem): bool {.inline.} =
  self.spectated

proc canRequestAccess*(self: SectionItem): bool {.inline.} =
  self.canRequestAccess

proc canManageUsers*(self: SectionItem): bool {.inline.} =
  self.canManageUsers

proc isMember*(self: SectionItem): bool {.inline.} =
  self.isMember

proc access*(self: SectionItem): int {.inline.} =
  self.access

proc ensOnly*(self: SectionItem): bool {.inline.} =
  self.ensOnly

proc muted*(self: SectionItem): bool {.inline.} = 
  self.muted

proc `muted=`*(self: var SectionItem, value: bool) {.inline.} = 
  self.muted = value

proc members*(self: SectionItem): member_model.Model {.inline.} =
  self.membersModel

proc hasMember*(self: SectionItem, pubkey: string): bool =
  self.membersModel.isContactWithIdAdded(pubkey)

proc setOnlineStatusForMember*(self: SectionItem, pubKey: string, onlineStatus: OnlineStatus) =
  self.membersModel.setOnlineStatus(pubkey, onlineStatus)

proc updateMember*(
    self: SectionItem,
    pubkey: string,
    name: string,
    ensName: string,
    isEnsVerified: bool,
    nickname: string,
    alias: string,
    image: string,
    isContact: bool,
    isVerified: bool,
    isUntrustworthy: bool) =
  self.membersModel.updateItem(pubkey, name, ensName, isEnsVerified, nickname, alias, image, isContact,
    isVerified, isUntrustworthy)

proc bannedMembers*(self: SectionItem): member_model.Model {.inline.} =
  self.bannedMembersModel

proc amIBanned*(self: SectionItem): bool {.inline.} =
  self.bannedMembersModel.isContactWithIdAdded(singletonInstance.userProfile.getPubKey())

proc pendingMemberRequests*(self: SectionItem): member_model.Model {.inline.} =
  self.pendingMemberRequestsModel

proc declinedMemberRequests*(self: SectionItem): member_model.Model {.inline.} =
  self.declinedMemberRequestsModel

proc isPendingOwnershipRequest*(self: SectionItem): bool {.inline.} =
  self.isPendingOwnershipRequest

proc setIsPendingOwnershipRequest*(self: var SectionItem, isPending: bool) {.inline.} =
  self.isPendingOwnershipRequest = isPending

proc pendingRequestsToJoin*(self: SectionItem): PendingRequestModel {.inline.} =
  self.pendingRequestsToJoinModel

proc historyArchiveSupportEnabled*(self: SectionItem): bool {.inline.} =
  self.historyArchiveSupportEnabled

proc pinMessageAllMembersEnabled*(self: SectionItem): bool {.inline.} =
  self.pinMessageAllMembersEnabled

proc encrypted*(self: SectionItem): bool {.inline.} =
  self.encrypted

proc appendCommunityToken*(self: SectionItem, item: TokenItem) {.inline.} =
  self.communityTokensModel.appendItem(item)

proc removeCommunityToken*(self: SectionItem, chainId: int, contractAddress: string) {.inline.} =
  self.communityTokensModel.removeItemByChainIdAndAddress(chainId, contractAddress)

proc updateCommunityTokenDeployState*(self: SectionItem, chainId: int, contractAddress: string, deployState: DeployState) {.inline.} =
  self.communityTokensModel.updateDeployState(chainId, contractAddress, deployState)

proc updateCommunityTokenAddress*(self: SectionItem, chainId: int, oldContractAddress: string, newContractAddress: string) {.inline.} =
  self.communityTokensModel.updateAddress(chainId, oldContractAddress, newContractAddress)

proc updateCommunityTokenSupply*(self: SectionItem, chainId: int, contractAddress: string, supply: Uint256, destructedAmount: Uint256) {.inline.} =
  self.communityTokensModel.updateSupply(chainId, contractAddress, supply, destructedAmount)

proc updateCommunityRemainingSupply*(self: SectionItem, chainId: int, contractAddress: string, remainingSupply: Uint256) {.inline.} =
  self.communityTokensModel.updateRemainingSupply(chainId, contractAddress, remainingSupply)

proc updateBurnState*(self: SectionItem, chainId: int, contractAddress: string, burnState: ContractTransactionStatus) {.inline.} =
  self.communityTokensModel.updateBurnState(chainId, contractAddress, burnState)

proc updateRemoteDestructedAddresses*(self: SectionItem, chainId: int, contractAddress: string, addresess: seq[string]) {.inline.} =
  self.communityTokensModel.updateRemoteDestructedAddresses(chainId, contractAddress, addresess)

proc setCommunityTokenOwners*(self: SectionItem, chainId: int, contractAddress: string, owners: seq[CommunityCollectibleOwner]) {.inline.} =
  self.communityTokensModel.setCommunityTokenOwners(chainId, contractAddress, owners)

proc communityTokens*(self: SectionItem): community_tokens_model.TokenModel {.inline.} =
  self.communityTokensModel

proc updatePendingRequestLoadingState*(self: SectionItem, memberKey: string, loading: bool) {.inline.} =
  self.pendingMemberRequestsModel.updateLoadingState(memberKey, loading)

proc updateMembershipStatus*(self: SectionItem, memberKey: string, status: MembershipRequestState) {.inline.} =
  if status == MembershipRequestState.UnbannedPending or status == MembershipRequestState.Banned:
    self.bannedMembersModel.updateMembershipStatus(memberKey, status)
  else:
    self.membersModel.updateMembershipStatus(memberKey, status)

proc pubsubTopic*(self: SectionItem): string {.inline.} =
  self.pubsubTopic

proc `pubsubTopic=`*(self: var SectionItem, value: string) {.inline.} =
  self.pubsubTopic = value

proc pubsubTopicKey*(self: SectionItem): string {.inline.} =
  self.pubsubTopicKey

proc `pubsubTopicKey=`*(self: var SectionItem, value: string) {.inline.} =
  self.pubsubTopicKey = value

proc shardIndex*(self: SectionItem): int {.inline.} =
  self.shardIndex

proc `shardIndex=`*(self: var SectionItem, value: int) {.inline.} =
  self.shardIndex = value
