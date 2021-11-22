import strformat
import base_item

export base_item

type 
  SubItem* = ref object of BaseItem

proc initSubItem*(id, name, icon, color, description: string, hasNotification: bool, notificationsCount: int, 
  muted, active: bool, position: int): SubItem =
  result = SubItem()
  result.setup(id, name, icon, color, description, hasNotification, notificationsCount, muted, active, position)

proc delete*(self: SubItem) = 
  self.BaseItem.delete

proc `$`*(self: SubItem): string =
  result = fmt"""ChatSectionSubItem(
    id: {self.id}, 
    name: {self.name}, 
    icon: {self.icon},
    color: {self.color}, 
    description: {self.description},
    hasNotification: {self.hasNotification}, 
    notificationsCount: {self.notificationsCount},
    muted: {self.muted},
    active: {self.active},
    position: {self.position},
    ]"""