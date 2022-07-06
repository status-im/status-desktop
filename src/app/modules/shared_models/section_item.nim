import strformat
import ./member_model, ./member_item
import ../main/communities/models/[pending_request_item, pending_request_model]

type
  SectionType* {.pure.} = enum
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
    amISectionAdmin: bool
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
    canManageUsers: bool
    canRequestAccess: bool
    access: int
    ensOnly: bool
    muted: bool
    membersModel: member_model.Model
    pendingRequestsToJoinModel: PendingRequestModel
    historyArchiveSupportEnabled: bool
    pinMessageAllMembersEnabled: bool

proc initItem*(
    id: string,
    sectionType: SectionType,
    name: string,
    amISectionAdmin = false,
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
    canManageUsers = false,
    canRequestAccess = false,
    isMember = false,
    access: int = 0,
    ensOnly = false,
    muted = false,
    members: seq[MemberItem] = @[],
    pendingRequestsToJoin: seq[PendingRequestItem] = @[],
    historyArchiveSupportEnabled = false,
    pinMessageAllMembersEnabled = false
    ): SectionItem =
  result.id = id
  result.sectionType = sectionType
  result.name = name
  result.amISectionAdmin = amISectionAdmin
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

proc isEmpty*(self: SectionItem): bool =
  return self.id.len == 0

proc `$`*(self: SectionItem): string =
  result = fmt"""SectionItem(
    id: {self.id},
    sectionType: {self.sectionType.int},
    name: {self.name},
    amISectionAdmin: {self.amISectionAdmin},
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
    canManageUsers:{self.canManageUsers},
    canRequestAccess:{self.canRequestAccess},
    isMember:{self.isMember},
    access:{self.access},
    ensOnly:{self.ensOnly},
    muted:{self.muted},
    members:{self.membersModel},
    historyArchiveSupportEnabled:{self.historyArchiveSupportEnabled},
    pinMessageAllMembersEnabled:{self.pinMessageAllMembersEnabled},
    ]"""

proc id*(self: SectionItem): string {.inline.} =
  self.id

proc sectionType*(self: SectionItem): SectionType {.inline.} =
  self.sectionType

proc name*(self: SectionItem): string {.inline.} =
  self.name

proc amISectionAdmin*(self: SectionItem): bool {.inline.} =
  self.amISectionAdmin

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

proc notificationsCount*(self: SectionItem): int {.inline.} =
  self.notificationsCount

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

proc setOnlineStatusForMember*(self: SectionItem, pubKey: string,
    onlineStatus: OnlineStatus) =
  self.membersModel.setOnlineStatus(pubkey, onlineStatus)

proc updateMember*(
    self: SectionItem,
    pubkey: string,
    name: string,
    ensName: string,
    nickname: string,
    alias: string,
    image: string,
    isContact: bool,
    isUntrustworthy: bool) =
  self.membersModel.updateItem(pubkey, name, ensName, nickname, alias, image, isContact,
    isUntrustworthy)

proc pendingRequestsToJoin*(self: SectionItem): PendingRequestModel {.inline.} =
  self.pendingRequestsToJoinModel

proc historyArchiveSupportEnabled*(self: SectionItem): bool {.inline.} =
  self.historyArchiveSupportEnabled

proc pinMessageAllMembersEnabled*(self: SectionItem): bool {.inline.} =
  self.pinMessageAllMembersEnabled
