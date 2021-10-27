import NimQml
import item

QtObject:
  type ActiveSection* = ref object of QObject
    item: Item

  proc setup(self: ActiveSection) =
    self.QObject.setup

  proc delete*(self: ActiveSection) =
    self.QObject.delete

  proc newActiveSection*(): ActiveSection =
    new(result, delete)
    result.setup

  proc setActiveSectionData*(self: ActiveSection, item: Item) =
    self.item = item

  proc getId(self: ActiveSection): string {.slot.} = 
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getSectionType(self: ActiveSection): int {.slot.} = 
    return self.item.sectionType.int

  QtProperty[int] sectionType:
    read = getSectionType

  proc getName(self: ActiveSection): string {.slot.} = 
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getImage(self: ActiveSection): string {.slot.} = 
    return self.item.image

  QtProperty[string] image:
    read = getImage

  proc getIcon(self: ActiveSection): string {.slot.} =
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getColor(self: ActiveSection): string {.slot.} =
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getHasNotification(self: ActiveSection): bool {.slot.} = 
    return self.item.hasNotification

  QtProperty[bool] hasNotification:
    read = getHasNotification

  proc getNotificationCount(self: ActiveSection): int {.slot.} = 
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  