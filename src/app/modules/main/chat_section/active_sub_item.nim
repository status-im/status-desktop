import NimQml
import sub_item

QtObject:
  type ActiveSubItem* = ref object of QObject
    item: SubItem

  proc setup(self: ActiveSubItem) =
    self.QObject.setup

  proc delete*(self: ActiveSubItem) =
    self.QObject.delete

  proc newActiveSubItem*(): ActiveSubItem =
    new(result, delete)
    result.setup

  proc setActiveSubItemData*(self: ActiveSubItem, item: SubItem) =
    self.item = item

  proc getId(self: ActiveSubItem): string {.slot.} = 
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getName(self: ActiveSubItem): string {.slot.} = 
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getIcon(self: ActiveSubItem): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveSubItem): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getDescription(self: ActiveSubItem): string {.slot.} = 
    return self.item.description

  QtProperty[string] description:
    read = getDescription

  proc getHasNotification(self: ActiveSubItem): bool {.slot.} = 
    return self.item.hasNotification

  QtProperty[bool] hasNotification:
    read = getHasNotification

  proc getNotificationCount(self: ActiveSubItem): int {.slot.} = 
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc getMuted(self: ActiveSubItem): bool {.slot.} = 
    return self.item.muted

  QtProperty[bool] muted:
    read = getMuted

  