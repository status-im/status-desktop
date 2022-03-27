import strformat
import ../../../app_service/service/contacts/dto/contacts

type
  OnlineStatus* {.pure.} = enum
    Offline = 0
    Online
    DoNotDisturb
    Idle
    Invisible

# TODO add role when it is needed
type
  Item* = ref object
    id: string
    displayName: string
    ensName: string
    localNickname: string
    alias: string
    onlineStatus: OnlineStatus
    icon: string
    isAdded: bool
    isAdmin: bool
    joined: bool
    trustStatus: TrustStatus

proc initItem*(
  id: string,
  displayName: string,
  ensName: string,
  localNickname: string,
  alias: string,
  onlineStatus: OnlineStatus,
  icon: string,
  isAdded: bool = false,
  isAdmin: bool = false,
  joined: bool = false,
  trustStatus: TrustStatus = TrustStatus.Unknown
): Item =
  result = Item()
  result.id = id
  result.displayName = displayName
  result.ensName = ensName
  result.localNickname = localNickname
  result.alias = alias
  result.onlineStatus = onlineStatus
  result.icon = icon
  result.isAdded = isAdded
  result.isAdmin = isAdmin
  result.joined = joined
  result.trustStatus = trustStatus

proc `$`*(self: Item): string =
  result = fmt"""User Item(
    id: {self.id},
    displayName: {self.displayName},
    localNickname: {self.localNickname},
    alias: {self.alias},
    onlineStatus: {$self.onlineStatus.int},
    icon: {self.icon},
    isAdded: {$self.isAdded},
    isAdmin: {$self.isAdmin},
    joined: {$self.joined},
    trustStatus: {self.trustStatus},
    ]"""

proc id*(self: Item): string {.inline.} =
  self.id

proc name*(self: Item): string {.inline.} =
  self.displayName

proc `name=`*(self: Item, value: string) {.inline.} =
  self.displayName = value

proc ensName*(self: Item): string {.inline.} =
  self.ensName

proc `ensName=`*(self: Item, value: string) {.inline.} =
  self.ensName = value

proc localNickname*(self: Item): string {.inline.} =
  self.localNickname

proc `localNickname=`*(self: Item, value: string) {.inline.} =
  self.localNickname = value

proc alias*(self: Item): string {.inline.} =
  self.alias

proc `alias=`*(self: Item, value: string) {.inline.} =
  self.alias = value

proc onlineStatus*(self: Item): OnlineStatus {.inline.} =
  self.onlineStatus

proc `onlineStatus=`*(self: Item, value: OnlineStatus) {.inline.} =
  self.onlineStatus = value

proc icon*(self: Item): string {.inline.} =
  self.icon

proc `icon=`*(self: Item, value: string) {.inline.} =
  self.icon = value

proc isAdmin*(self: Item): bool {.inline.} =
  self.isAdmin

proc `isAdmin=`*(self: Item, value: bool) {.inline.} =
  self.isAdmin = value

proc isAdded*(self: Item): bool {.inline.} =
  self.isAdded

proc `isAdded=`*(self: Item, value: bool) {.inline.} =
  self.isAdded = value

proc joined*(self: Item): bool {.inline.} =
  self.joined

proc `joined=`*(self: Item, value: bool) {.inline.} =
  self.joined = value

proc trustStatus*(self: Item): TrustStatus {.inline.} =
  self.trustStatus

proc `trustStatus=`*(self: Item, value: TrustStatus) {.inline.} =
  self.trustStatus = value
