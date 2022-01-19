import strformat
import ./members_model, ./member_item
import ../main/communities/models/[pending_request_item, pending_request_model]

type
  SectionType* {.pure.} = enum
    Chat = 0
    Community,
    Wallet,
    WalletV2,
    Browser,
    ProfileSettings,
    NodeManagement

type 
  SectionItem* = object
    sectionType: SectionType
    id: string
    name: string
    amISectionAdmin: bool
    description: string
    image: string
    icon: string
    color: string
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
    membersModel: MembersModel
    pendingRequestsToJoinModel: PendingRequestModel

proc initItem*(
    id: string,
    sectionType: SectionType,
    name: string,
    amISectionAdmin = false,
    description = "",
    image = "",
    icon = "",
    color = "",
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
    members: seq[MemberItem] = @[],
    pendingRequestsToJoin: seq[PendingRequestItem] = @[]
    ): SectionItem =
  result.id = id
  result.sectionType = sectionType
  result.name = name
  result.amISectionAdmin = amISectionAdmin
  result.description = description
  result.image = image
  result.icon = icon
  result.color = color
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
  result.membersModel = newMembersModel(members)
  result.pendingRequestsToJoinModel = newPendingRequestModel(pendingRequestsToJoin)

proc isEmpty*(self: SectionItem): bool =
  return self.id.len == 0

proc `$`*(self: SectionItem): string =
  result = fmt"""SectionItem(
    id: {self.id},
    sectionType: {self.sectionType.int},
    name: {self.name},
    amISectionAdmin: {self.amISectionAdmin},
    description: {self.description}, 
    image: {self.image},
    icon: {self.icon},
    color: {self.color},
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
    members:{self.membersModel},
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

proc image*(self: SectionItem): string {.inline.} = 
  self.image

proc icon*(self: SectionItem): string {.inline.} = 
  self.icon

proc color*(self: SectionItem): string {.inline.} = 
  self.color

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

proc members*(self: SectionItem): MembersModel {.inline.} =
  self.membersModel

proc hasMember*(self: SectionItem, pubkey: string): bool =
  self.membersModel.hasMember(pubkey)

proc pendingRequestsToJoin*(self: SectionItem): PendingRequestModel {.inline.} = 
  self.pendingRequestsToJoinModel