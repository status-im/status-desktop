import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/message/dto/[message]

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasMoreToShow*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method unreadActivityCenterNotificationsCount*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetails*(self: AccessInterface, contactId: string): ContactDetails {.base.} =
  raise newException(ValueError, "No implementation available")

method getActivityCenterNotifications*(self: AccessInterface): seq[ActivityCenterNotificationDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllActivityCenterNotificationsRead*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationRead*(self: AccessInterface, notificationId: string, markAsReadProps: MarkAsReadNotificationProperties): string {.base.} =
  raise newException(ValueError, "No implementation available")

method markActivityCenterNotificationUnread*(self: AccessInterface, notificationId: string, markAsUnreadProps: MarkAsUnreadNotificationProperties): string {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptActivityCenterNotifications*(self: AccessInterface, notificationIds: seq[string]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method dismissActivityCenterNotifications*(self: AccessInterface, notificationIds: seq[string]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getRenderedText*(self: AccessInterface, parsedTextArray: seq[ParsedText]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method decodeContentHash*(self: AccessInterface, hash: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")


type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
