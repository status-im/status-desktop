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

  proc getId*(self: ActiveSubItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.id

  QtProperty[string] id:
    read = getId

  proc getName(self: ActiveSubItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getAmIChatAdmin(self: ActiveSubItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.amIChatAdmin

  QtProperty[bool] amIChatAdmin:
    read = getAmIChatAdmin

  proc getIcon(self: ActiveSubItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.icon

  QtProperty[string] icon:
    read = getIcon

  proc getIsIdenticon(self: ActiveSubItem): bool {.slot.} =
    if(self.item.isNil):
      return true
    return self.item.isIdenticon

  QtProperty[bool] isIdenticon:
    read = getIsIdenticon

  proc getColor(self: ActiveSubItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.color

  QtProperty[string] color:
    read = getColor

  proc getDescription(self: ActiveSubItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.description

  QtProperty[string] description:
    read = getDescription

  proc getHasUnreadMessages(self: ActiveSubItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.hasUnreadMessages

  QtProperty[bool] hasUnreadMessages:
    read = getHasUnreadMessages

  proc getNotificationCount(self: ActiveSubItem): int {.slot.} =
    if(self.item.isNil):
      return 0
    return self.item.notificationsCount

  QtProperty[int] notificationCount:
    read = getNotificationCount

  proc getMuted(self: ActiveSubItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.muted
  QtProperty[bool] muted:
    read = getMuted

  proc getBlocked(self: ActiveSubItem): bool {.slot.} =
    if(self.item.isNil):
      return false
    return self.item.blocked
  QtProperty[bool] blocked:
    read = getBlocked

  proc getPosition(self: ActiveSubItem): int {.slot.} =
    if(self.item.isNil):
      return 0
    return self.item.position

  QtProperty[int] position:
    read = getPosition

