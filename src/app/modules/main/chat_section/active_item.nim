import NimQml
import item, sub_item, active_sub_item

QtObject:
  type ActiveItem* = ref object of QObject
    item: Item
    activeSubItem: ActiveSubItem
    activeSubItemVariant: QVariant

  proc setup(self: ActiveItem) =
    self.QObject.setup
    self.activeSubItem = newActiveSubItem()
    self.activeSubItemVariant = newQVariant(self.activeSubItem)

  proc delete*(self: ActiveItem) =
    self.activeSubItem.delete
    self.activeSubItemVariant.delete
    self.QObject.delete

  proc newActiveItem*(): ActiveItem =
    new(result, delete)
    result.setup

  #################################################
  # Forward declaration section
  proc activeSubItemChanged(self: ActiveItem) {.signal.}  

  #################################################

  proc setActiveItemData*(self: ActiveItem, item: Item, subItem: SubItem) =
    self.item = item
    self.activeSubItem.setActiveSubItemData(subItem)
    self.activeSubItemChanged()

  proc getId(self: ActiveItem): string {.slot.} = 
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getName(self: ActiveItem): string {.slot.} = 
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getIcon(self: ActiveItem): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveItem): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getDescription(self: ActiveItem): string {.slot.} = 
    return self.item.description

  QtProperty[string] description:
    read = getDescription

  proc getType(self: ActiveItem): int {.slot.} = 
    return self.item.`type`

  QtProperty[int] type:
    read = getType

  proc getHasNotification(self: ActiveItem): bool {.slot.} = 
    return self.item.hasNotification

  QtProperty[bool] hasNotification:
    read = getHasNotification

  proc getNotificationCount(self: ActiveItem): int {.slot.} = 
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc getMuted(self: ActiveItem): bool {.slot.} = 
    return self.item.muted

  QtProperty[bool] muted:
    read = getMuted

  proc getPosition(self: ActiveItem): int {.slot.} = 
    return self.item.position

  QtProperty[int] position:
    read = getPosition

  proc getActiveSubItem(self: ActiveItem): QVariant {.slot.} = 
    return self.activeSubItemVariant

  QtProperty[QVariant] activeSubItem:
    read = getActiveSubItem
    notify = activeSubItemChanged

  