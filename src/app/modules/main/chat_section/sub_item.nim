import strformat, json
import base_item

export base_item

type
  SubItem* = ref object of BaseItem
    parentId: string

proc initSubItem*(id, parentId, name, icon: string, color, emoji, description: string,
  `type`: int, amIChatAdmin: bool, lastMessageTimestamp: int, hasUnreadMessages: bool, notificationsCount: int, muted, blocked,
  active: bool, position: int): SubItem =
  result = SubItem()
  result.setup(id, name, icon, color, emoji, description, `type`, amIChatAdmin, lastMessageTimestamp, 
    hasUnreadMessages, notificationsCount, muted, blocked, active, position)
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
    color: {self.color},
    emoji: {self.emoji},
    description: {self.description},
    type: {self.`type`},
    lastMessageTimestamp: {self.lastMessageTimestamp},
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
    "color": self.color,
    "emoji": self.emoji,
    "description": self.description,
    "type": self.`type`,
    "lastMessageTimestamp": self.lastMessageTimestamp,
    "hasUnreadMessages": self.hasUnreadMessages,
    "notificationsCount": self.notificationsCount,
    "muted": self.muted,
    "blocked": self.blocked,
    "active": self.active,
    "position": self.position
  }
