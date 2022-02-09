import strformat, json
import base_item

export base_item

type
  SubItem* = ref object of BaseItem
    parentId: string

proc initSubItem*(id, parentId, name, icon: string, isIdenticon: bool, color, description: string, `type`: int,
  amIChatAdmin: bool, hasUnreadMessages: bool, notificationsCount: int, muted, blocked, active: bool, position: int): SubItem =
  result = SubItem()
  result.setup(id, name, icon, isIdenticon, color, description, `type`, amIChatAdmin, hasUnreadMessages,
  notificationsCount, muted, blocked, active, position)
  result.parentId = parentId

proc delete*(self: SubItem) =
  self.BaseItem.delete

proc parentId*(self: SubItem): string =
  self.parentId

proc `$`*(self: SubItem): string =
  result = fmt"""ChatSectionSubItem(
    itemId: {self.id},
    parentItemId: {self.parentId},
    name: {self.name},
    amIChatAdmin: {self.amIChatAdmin},
    icon: {self.icon},
    isIdenticon: {self.isIdenticon},
    color: {self.color},
    description: {self.description},
    type: {self.`type`},
    hasUnreadMessages: {self.hasUnreadMessages},
    notificationsCount: {self.notificationsCount},
    muted: {self.muted},
    blocked: {self.blocked},
    active: {self.active},
    position: {self.position},
    ]"""

proc toJsonNode*(self: SubItem): JsonNode =
  result = %* {
    "itemId": self.id,
    "name": self.name,
    "amIChatAdmin": self.amIChatAdmin,
    "icon": self.icon,
    "isIdenticon": self.isIdenticon,
    "color": self.color,
    "description": self.description,
    "type": self.`type`,
    "hasUnreadMessages": self.hasUnreadMessages,
    "notificationsCount": self.notificationsCount,
    "muted": self.muted,
    "blocked": self.blocked,
    "active": self.active,
    "position": self.position
  }
