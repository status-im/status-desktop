import Tables, stint
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

method convertToItems*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]): seq[Item] {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchActivityCenterNotifications*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllActivityCenterNotificationsRead*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllActivityCenterNotificationsReadDone*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissActivityCenterNotificationsDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationReadDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationUnreadDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptActivityCenterNotificationsDone*(self: AccessInterface, notificationIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationRead*(self: AccessInterface, notificationId: string, communityId: string, channelId: string, nType: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationUnread*(self: AccessInterface, notificationId: string, communityId: string, channelId: string, nType: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method pushActivityCenterNotifications*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method addActivityCenterNotification*(self: AccessInterface, activityCenterNotifications: seq[ActivityCenterNotificationDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptActivityCenterNotifications*(self: AccessInterface, notificationIds: seq[string]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissActivityCenterNotifications*(self: AccessInterface, notificationIds: seq[string]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDetails*(self: AccessInterface, sectionId: string, chatId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")