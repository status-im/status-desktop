import NimQml
import item
import ../../../../app_service/common/types

QtObject:
  type ActiveItem* = ref object of QObject
    item: Item

  proc setup(self: ActiveItem) =
    self.QObject.setup

  proc delete*(self: ActiveItem) =
    self.QObject.delete

  proc newActiveItem*(): ActiveItem =
    new(result, delete)
    result.setup

  #################################################
  # Forward declaration section
  proc idChanged(self: ActiveItem) {.signal.}

  #################################################

  proc setActiveItemData*(self: ActiveItem, item: Item) =
    self.item = item

  # Used when there is no longer an active item (last channel was deleted)
  proc resetActiveItemData*(self: ActiveItem) =
    self.item = Item()
    self.idChanged()

  proc getId(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.id

  QtProperty[string] id:
    read = getId
    notify = idChanged

  proc getName(self: ActiveItem): string {.slot.} =
    if(self.item.isNil):
      return ""
    return self.item.name

  QtProperty[string] name:
    read = getName

  proc getMemberRole(self: ActiveItem): int {.slot.} =
    if(self.item.isNil):
      return MemberRole.None.int
    return self.item.memberRole.int

  QtProperty[int] memberRole:
    read = getMemberRole

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
