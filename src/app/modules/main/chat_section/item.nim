import sequtils, sugar, strformat, json

import ../../../../app_service/common/types
import ../../../../app_service/service/contacts/dto/contacts

import ../../shared_models/[color_hash_item, color_hash_model]

const CATEGORY_TYPE* = -1

type
  Item* = ref object
    id: string
    name: string
    `type`: int
    memberRole: MemberRole
    icon: string
    color: string
    colorId: int # only for oneToOne sections
    emoji: string
    colorHash: color_hash_model.Model
    description: string
    lastMessageTimestamp: int
    hasUnreadMessages: bool
    notificationsCount: int
    muted: bool
    blocked: bool
    active: bool
    position: int
    categoryId: string
    categoryPosition: int
    categoryOpened: bool
    highlight: bool
    trustStatus: TrustStatus
    onlineStatus: OnlineStatus
    loaderActive: bool
    locked: bool
    requiresPermissions: bool

proc initItem*(
    id,
    name,
    icon,
    color,
    emoji,
    description: string,
    `type`: int,
    memberRole: MemberRole,
    lastMessageTimestamp: int,
    hasUnreadMessages: bool,
    notificationsCount: int,
    muted,
    blocked,
    active: bool,
    position: int,
    categoryId: string = "",
    categoryPosition: int = -1,
    colorId: int = 0,
    colorHash: seq[ColorHashSegment] = @[],
    highlight: bool = false,
    categoryOpened: bool = true,
    trustStatus: TrustStatus = TrustStatus.Unknown,
    onlineStatus = OnlineStatus.Inactive,
    loaderActive = false,
    locked = false,
    requiresPermissions = false
    ): Item =
  result = Item()
  result.id = id
  result.name = name
  result.memberRole = memberRole
  result.icon = icon
  result.color = color
  result.colorId = colorId
  result.emoji = emoji
  result.colorHash = color_hash_model.newModel()
  result.colorHash.setItems(map(colorHash, x => color_hash_item.initItem(x.len, x.colorIdx)))
  result.description = description
  result.`type` = `type`
  result.lastMessageTimestamp = lastMessageTimestamp
  result.hasUnreadMessages = hasUnreadMessages
  result.notificationsCount = notificationsCount
  result.muted = muted
  result.blocked = blocked
  result.active = active
  result.position = position
  result.categoryId = categoryId
  result.categoryPosition = categoryPosition
  result.highlight = highlight
  result.categoryOpened = categoryOpened
  result.trustStatus = trustStatus
  result.onlineStatus = onlineStatus
  result.loaderActive = loaderActive
  result.locked = locked
  result.requiresPermissions = requiresPermissions

proc `$`*(self: Item): string =
  result = fmt"""chat_section/Item(
    id: {self.id},
    name: {$self.name},
    memberRole: {$self.memberRole},
    icon: {$self.icon},
    color: {$self.color},
    colorId: {$self.colorId},
    emoji: {$self.emoji},
    description: {$self.description},
    type: {$self.`type`},
    lastMessageTimestamp: {$self.lastMessageTimestamp},
    hasUnreadMessages: {$self.hasUnreadMessages},
    notificationsCount: {$self.notificationsCount},
    muted: {$self.muted},
    blocked: {$self.blocked},
    active: {$self.active},
    position: {$self.position},
    categoryId: {$self.categoryId},
    categoryPosition: {$self.categoryPosition},
    highlight: {$self.highlight},
    categoryOpened: {$self.categoryOpened},
    trustStatus: {$self.trustStatus},
    onlineStatus: {$self.onlineStatus},
    loaderActive: {$self.loaderActive},
    locked: {$self.locked},
    requiresPermissions: {$self.requiresPermissions},
    ]"""

proc toJsonNode*(self: Item): JsonNode =
  result = %* {
    "itemId": self.id,
    "name": self.name,
    "memberRole": self.memberRole,
    "icon": self.icon,
    "color": self.color,
    "colorId": self.colorId,
    "emoji": self.emoji,
    "description": self.description,
    "type": self.`type`,
    "lastMessageTimestamp": self.lastMessageTimestamp,
    "hasUnreadMessages": self.hasUnreadMessages,
    "notificationsCount": self.notificationsCount,
    "muted": self.muted,
    "blocked": self.blocked,
    "active": self.active,
    "position": self.position,
    "categoryId": self.categoryId,
    "categoryPosition": self.categoryPosition,
    "highlight": self.highlight,
    "categoryOpened": self.categoryOpened,
    "trustStatus": self.trustStatus,
    "onlineStatus": self.onlineStatus,
    "loaderActive": self.loaderActive,
    "locked": self.locked,
    "requiresPermissions": self.requiresPermissions
  }

proc delete*(self: Item) =
  discard

proc id*(self: Item): string =
  self.id

proc name*(self: Item): string =
  self.name

proc `name=`*(self: var Item, value: string) =
  self.name = value

proc memberRole*(self: Item): MemberRole =
  self.memberRole

proc icon*(self: Item): string =
  self.icon

proc `icon=`*(self: var Item, value: string) =
  self.icon = value

proc color*(self: Item): string =
  self.color

proc `color=`*(self: var Item, value: string) =
  self.color = value

proc colorId*(self: Item): int =
  self.colorId

proc emoji*(self: Item): string =
  self.emoji

proc `emoji=`*(self: var Item, value: string) =
  self.emoji = value

proc colorHash*(self: Item): color_hash_model.Model =
  self.colorHash

proc description*(self: Item): string =
  self.description

proc `description=`*(self: var Item, value: string) =
  self.description = value

proc type*(self: Item): int =
  self.`type`

proc hasUnreadMessages*(self: Item): bool =
  self.hasUnreadMessages

proc `hasUnreadMessages=`*(self: var Item, value: bool) =
  self.hasUnreadMessages = value

proc lastMessageTimestamp*(self: Item): int =
  self.lastMessageTimestamp

proc `lastMessageTimestamp=`*(self: var Item, value: int) =
  self.lastMessageTimestamp = value

proc notificationsCount*(self: Item): int =
  self.notificationsCount

proc `notificationsCount=`*(self: var Item, value: int) =
  self.notificationsCount = value

proc muted*(self: Item): bool =
  self.muted

proc `muted=`*(self: Item, value: bool) =
  self.muted = value

proc blocked*(self: Item): bool =
  self.blocked

proc `blocked=`*(self: var Item, value: bool) =
  self.blocked = value

proc active*(self: Item): bool =
  self.active

proc `active=`*(self: var Item, value: bool) =
  self.active = value

proc position*(self: Item): int =
  self.position

proc `position=`*(self: var Item, value: int) =
  self.position = value

proc categoryId*(self: Item): string =
  self.categoryId

proc `categoryId=`*(self: var Item, value: string) =
  self.categoryId = value

proc categoryPosition*(self: Item): int =
  self.categoryPosition

proc `categoryPosition=`*(self: var Item, value: int) =
  self.categoryPosition = value

proc highlight*(self: Item): bool =
  self.highlight

proc `highlight=`*(self: var Item, value: bool) =
  self.highlight = value

proc categoryOpened*(self: Item): bool =
  self.categoryOpened

proc `categoryOpened=`*(self: var Item, value: bool) =
  self.categoryOpened = value

proc trustStatus*(self: Item): TrustStatus =
  self.trustStatus

proc `trustStatus=`*(self: var Item, value: TrustStatus) =
  self.trustStatus = value

proc onlineStatus*(self: Item): OnlineStatus =
  self.onlineStatus

proc `onlineStatus=`*(self: var Item, value: OnlineStatus) =
  self.onlineStatus = value

proc setHasUnreadMessages*(self: Item, value: bool) =
  self.hasUnreadMessages = value

proc loaderActive*(self: Item): bool =
  self.loaderActive

proc `loaderActive=`*(self: var Item, value: bool) =
  self.loaderActive = value

proc isCategory*(self: Item): bool =
  self.`type` == CATEGORY_TYPE

proc isLocked*(self: Item): bool =
  self.locked

proc `locked=`*(self: Item, value: bool) =
  self.locked = value

proc requiresPermissions*(self: Item): bool =
  self.requiresPermissions

proc `requiresPermissions=`*(self: Item, value: bool) =
  self.requiresPermissions = value
