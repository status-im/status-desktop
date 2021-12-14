import json, strformat

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
  Item* = object
    sectionType: SectionType
    id: string
    name: string
    description: string
    image: string
    icon: string
    color: string
    hasNotification: bool
    notificationsCount: int
    active: bool
    enabled: bool

proc initItem*(
    id: string,
    sectionType: SectionType,
    name,
    description = "",
    image = "",
    icon = "",
    color = "",
    hasNotification = false, 
    notificationsCount: int = 0,
    active = false,
    enabled = true
    ): Item =
  result.id = id
  result.sectionType = sectionType
  result.name = name
  result.description = description
  result.image = image
  result.icon = icon
  result.color = color
  result.hasNotification = hasNotification
  result.notificationsCount = notificationsCount
  result.active = active
  result.enabled = enabled

proc isEmpty*(self: Item): bool =
  return self.id.len == 0

proc `$`*(self: Item): string =
  result = fmt"""MainModuleItem(
    id: {self.id},
    sectionType: {self.sectionType.int},
    name: {self.name},
    description: {self.description}, 
    image: {self.image},
    icon: {self.icon},
    color: {self.color},
    hasNotification: {self.hasNotification},
    notificationsCount:{self.notificationsCount},
    active:{self.active},
    enabled:{self.enabled}
    ]"""

proc id*(self: Item): string {.inline.} = 
  self.id

proc sectionType*(self: Item): SectionType {.inline.} = 
  self.sectionType

proc name*(self: Item): string {.inline.} = 
  self.name

proc description*(self: Item): string {.inline.} = 
  self.description

proc image*(self: Item): string {.inline.} = 
  self.image

proc icon*(self: Item): string {.inline.} = 
  self.icon

proc color*(self: Item): string {.inline.} = 
  self.color

proc hasNotification*(self: Item): bool {.inline.} = 
  self.hasNotification

proc `hasNotification=`*(self: var Item, value: bool) {.inline.} = 
  self.hasNotification = value

proc notificationsCount*(self: Item): int {.inline.} = 
  self.notificationsCount

proc `notificationsCount=`*(self: var Item, value: int) {.inline.} = 
  self.notificationsCount = value

proc active*(self: Item): bool {.inline.} = 
  self.active

proc `active=`*(self: var Item, value: bool) {.inline.} = 
  self.active = value

proc enabled*(self: Item): bool {.inline.} = 
  self.enabled

proc `enabled=`*(self: var Item, value: bool) {.inline.} = 
  self.enabled = value