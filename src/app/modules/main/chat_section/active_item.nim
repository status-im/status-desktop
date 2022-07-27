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
  proc idChanged(self: ActiveItem) {.signal.}

  #################################################

  proc setActiveItemData*(self: ActiveItem, item: Item, subItem: SubItem) =
    self.item = item
    self.activeSubItem.setActiveSubItemData(subItem)
    self.activeSubItemChanged()

  # Used when there is no longer an active item (last channel was deleted)
  proc resetActiveItemData*(self: ActiveItem) =
    self.item = Item()
    self.activeSubItem.setActiveSubItemData(SubItem())
    self.idChanged()
    self.activeSubItemChanged()

  proc getId(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.id

  QtProperty[string] id:
    read = getId
    notify = idChanged

  proc getIsSubItemActive(self: ActiveItem): bool {.slot.} =
    if(self.activeSubItem.getId().len > 0):
      return true

    return false

  QtProperty[bool] isSubItemActive:
    read = getIsSubItemActive

  proc getName(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getAmIChatAdmin(self: ActiveItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.amIChatAdmin

  QtProperty[bool] amIChatAdmin:
    read = getAmIChatAdmin

  proc getIcon(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getDescription(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.description

  QtProperty[string] description:
    read = getDescription

  proc getType(self: ActiveItem): int {.slot.} =
    if(self.item.isNil):
      return 0
    return self.item.`type`

  QtProperty[int] type:
    read = getType

  proc getHasUnreadMessages(self: ActiveItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.hasUnreadMessages

  QtProperty[bool] hasUnreadMessages:
    read = getHasUnreadMessages

  proc getNotificationCount(self: ActiveItem): int {.slot.} =
    if(self.item.isNil):
      return 0
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc getMuted(self: ActiveItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.muted
  QtProperty[bool] muted:
    read = getMuted

  proc getBlocked(self: ActiveItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.blocked
  QtProperty[bool] blocked:
    read = getBlocked

  proc getPosition(self: ActiveItem): int {.slot.} =
    if(self.item.isNil):
      return 0
    return self.item.position

  QtProperty[int] position:
    read = getPosition

  proc getActiveSubItem(self: ActiveItem): QVariant {.slot.} =
    return self.activeSubItemVariant

  QtProperty[QVariant] activeSubItem:
    read = getActiveSubItem
    notify = activeSubItemChanged

