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
    name: string
    onlineStatus: OnlineStatus
    icon: string
    isIdenticon: bool
    isAdmin: bool
    joined: bool

proc initItem*(
  id: string,
  name: string,
  onlineStatus: OnlineStatus,
  icon: string,
  isidenticon: bool,
  isAdmin: bool = false,
  joined: bool = false,
): Item =
  result = Item()
  result.id = id
  result.name = name
  result.onlineStatus = onlineStatus
  result.icon = icon
  result.isIdenticon = isidenticon
  result.isAdmin = isAdmin
  result.joined = joined

proc `$`*(self: Item): string =
  result = fmt"""User Item(
    id: {self.id},
    name: {self.name},
    onlineStatus: {$self.onlineStatus.int},
    icon: {self.icon},
    isIdenticon: {$self.isIdenticon}
    isAdmin: {$self.isAdmin}
    joined: {$self.joined}
    ]"""

proc id*(self: Item): string {.inline.} =
  self.id

proc name*(self: Item): string {.inline.} =
  self.name

proc `name=`*(self: Item, value: string) {.inline.} =
  self.name = value

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
