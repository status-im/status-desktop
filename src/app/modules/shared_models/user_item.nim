import strformat

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
    isIdenticon: bool
    isAdmin: bool
    joined: bool

proc initItem*(
  id: string,
  displayName: string,
  ensName: string,
  localNickname: string,
  alias: string,
  onlineStatus: OnlineStatus,
  icon: string,
  isidenticon: bool,
  isAdmin: bool = false,
  joined: bool = false,
): Item =
  result = Item()
  result.id = id
  result.displayName = displayName
  result.ensName = ensName
  result.localNickname = localNickname
  result.alias = alias
  result.onlineStatus = onlineStatus
  result.icon = icon
  result.isIdenticon = isidenticon
  result.isAdmin = isAdmin
  result.joined = joined

proc `$`*(self: Item): string =
  result = fmt"""User Item(
    id: {self.id},
    displayName: {self.displayName},
    localNickname: {self.localNickname},
    alias: {self.alias},
    onlineStatus: {$self.onlineStatus.int},
    icon: {self.icon},
    isIdenticon: {$self.isIdenticon}
    isAdmin: {$self.isAdmin}
    joined: {$self.joined}
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

proc isIdenticon*(self: Item): bool {.inline.} =
  self.isIdenticon

proc `isIdenticon=`*(self: Item, value: bool) {.inline.} =
  self.isIdenticon = value

proc isAdmin*(self: Item): bool {.inline.} =
  self.isAdmin

proc `isAdmin=`*(self: Item, value: bool) {.inline.} =
  self.isAdmin = value

proc joined*(self: Item): bool {.inline.} =
  self.joined

proc `joined=`*(self: Item, value: bool) {.inline.} =
  self.joined = value
