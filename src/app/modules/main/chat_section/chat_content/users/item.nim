type
  OnlineStatus* {.pure.} = enum
    Online = 0
    Idle
    DoNotDisturb
    Invisible
    Offline

type 
  Item* = ref object
    id: string
    name: string
    onlineStatus: OnlineStatus
    identicon: string

proc initItem*(id: string, name: string, onlineStatus: OnlineStatus, identicon: string): Item =
  result = Item()
  result.id = id
  result.name = name
  result.onlineStatus = onlineStatus
  result.identicon = identicon

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

proc identicon*(self: Item): string {.inline.} = 
  self.identicon