import strformat
import base_item, sub_model, sub_item

type 
  Item* = ref object of BaseItem
    `type`: int
    subItems: SubModel

proc initItem*(id, name, icon, color, description: string, `type`: int, hasNotification: bool, notificationsCount: int, 
  muted, active: bool): Item =
  result = Item()
  result.setup(id, name, icon, color, description, hasNotification, notificationsCount, muted, active)
  result.`type` = `type`
  result.subItems = newSubModel()

proc delete*(self: Item) = 
  self.subItems.delete
  self.delete

proc subItems*(self: Item): SubModel {.inline.} = 
  self.subItems

proc type*(self: Item): int {.inline.} = 
  self.`type`

proc `$`*(self: Item): string =
  result = fmt"""ChatSectionItem(
    id: {self.id}, 
    name: {self.name}, 
    icon: {self.icon},
    color: {self.color}, 
    description: {self.description},
    type: {self.`type`},
    hasNotification: {self.hasNotification}, 
    notificationsCount: {self.notificationsCount},
    muted: {self.muted},
    active: {self.active},
    subItems:[
      {$self.subItems}
    ]"""

proc appendSubItems*(self: Item, items: seq[SubItem]) =
  self.subItems.appendItems(items)

proc appendSubItem*(self: Item, item: SubItem) =
  self.subItems.appendItem(item)

proc prependSubItems*(self: Item, items: seq[SubItem]) =
  self.subItems.prependItems(items)

proc prependSubItem*(self: Item, item: SubItem) =
  self.subItems.prependItem(item)

proc setActiveSubItem*(self: Item, subItemId: string) =
  self.subItems.setActiveItem(subItemId)