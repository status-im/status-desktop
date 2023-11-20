import Tables
import ./item
import ../../../../app_service/service/activity_center/service as activity_center_service

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasMoreToShow*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method unreadActivityCenterNotificationsCount*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method hasUnseenActivityCenterNotifications*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method onNotificationsCountMayHaveChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasUnseenActivityCenterNotificationsChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method convertToItems*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]): seq[Item] {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchActivityCenterNotifications*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllActivityCenterNotificationsRead*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllActivityCenterNotificationsReadDone*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationReadDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationUnreadDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeActivityCenterNotifications*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationRead*(self: AccessInterface, notificationId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationUnread*(self: AccessInterface, notificationId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAsSeenActivityCenterNotifications*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addActivityCenterNotifications*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method resetActivityCenterNotifications*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDetails*(self: AccessInterface, sectionId: string, chatId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatDetailsAsJson*(self: AccessInterface, chatId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveNotificationGroup*(self: AccessInterface, group: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveNotificationGroup*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setActivityCenterReadType*(self: AccessInterface, readType: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActivityCenterReadType*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setActivityGroupCounters*(self: AccessInterface, counters: Table[ActivityCenterGroup, int]) {.base.} =
  raise newException(ValueError, "No implementation available")
