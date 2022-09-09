import strformat, json
import base_item, sub_model, sub_item
import ../../shared_models/color_hash_model

import ../../../../app_service/common/types
import ../../../../app_service/service/contacts/dto/contacts

type
  Item* = ref object of BaseItem
    subItems: SubModel

proc initItem*(id, name, icon: string, color, emoji, description: string,
    `type`: int, amIChatAdmin: bool, lastMessageTimestamp: int, hasUnreadMessages: bool, notificationsCount: int, muted,
    blocked, active: bool, position: int, categoryId: string, colorId: int = 0, colorHash: seq[ColorHashSegment] = @[], highlight: bool = false,
    trustStatus: TrustStatus = TrustStatus.Unknown, onlineStatus = OnlineStatus.Inactive): Item =
  result = Item()
  result.setup(id, name, icon, color, emoji, description, `type`, amIChatAdmin, lastMessageTimestamp, hasUnreadMessages,
  notificationsCount, muted, blocked, active, position, categoryId, colorId, colorHash, highlight, trustStatus, onlineStatus)
  result.subItems = newSubModel()

proc delete*(self: Item) =
  self.subItems.delete
  self.BaseItem.delete

proc subItems*(self: Item): SubModel {.inline.} =
  self.subItems

proc `$`*(self: Item): string =
  result = fmt"""ChatSectionItem(
    itemId: {self.id},
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
    categoryId: {self.categoryId},
    highlight: {self.highlight},
    trustStatus: {self.trustStatus},
    onlineStatus: {self.onlineStatus},
    subItems:[
      {$self.subItems}
    ]"""

proc toJsonNode*(self: Item): JsonNode =
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
    "position": self.position,
    "categoryId": self.categoryId,
    "highlight": self.highlight,
    "trustStatus": self.trustStatus,
    "onlineStatus": self.onlineStatus
  }

proc appendSubItems*(self: Item, items: seq[SubItem]) =
  self.subItems.appendItems(items)
  self.BaseItem.muted = self.subItems.isAllMuted()

proc appendSubItem*(self: Item, item: SubItem) =
  self.subItems.appendItem(item)
  self.BaseItem.muted = self.subItems.isAllMuted()

proc setActiveSubItem*(self: Item, subItemId: string) =
  self.subItems.setActiveItem(subItemId)
