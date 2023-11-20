import NimQml, json, strutils, sequtils, std/tables
import ../../../../app_service/service/activity_center/service as activity_center_service

import ./model
import ./io_interface, ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      groupCounters: Table[ActivityCenterGroup, int]

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.groupCounters = initTable[ActivityCenterGroup, int]()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc activityNotificationsChanged*(self: View) {.signal.}

  proc getActivityNotificationModel(self: View): QVariant {.slot.} =
    return newQVariant(self.modelVariant)

  QtProperty[QVariant] activityNotificationsModel:
    read = getActivityNotificationModel
    notify = activityNotificationsChanged

  proc hasMoreToShowChanged*(self: View) {.signal.}

  proc hasMoreToShow*(self: View): bool {.slot.}  =
    self.delegate.hasMoreToShow()

  QtProperty[bool] hasMoreToShow:
    read = hasMoreToShow
    notify = hasMoreToShowChanged

  proc unreadActivityCenterNotificationsCountChanged*(self: View) {.signal.}

  proc unreadActivityCenterNotificationsCount*(self: View): int {.slot.}  =
    self.delegate.unreadActivityCenterNotificationsCount()

  QtProperty[int] unreadActivityCenterNotificationsCount:
    read = unreadActivityCenterNotificationsCount
    notify = unreadActivityCenterNotificationsCountChanged

  proc hasUnseenActivityCenterNotificationsChanged*(self: View) {.signal.}

  proc hasUnseenActivityCenterNotifications*(self: View): bool {.slot.}  =
    self.delegate.hasUnseenActivityCenterNotifications()

  QtProperty[bool] hasUnseenActivityCenterNotifications:
    read = hasUnseenActivityCenterNotifications
    notify = hasUnseenActivityCenterNotificationsChanged

  proc fetchActivityCenterNotifications(self: View) {.slot.} =
    self.delegate.fetchActivityCenterNotifications()

  proc markAllActivityCenterNotificationsRead(self: View): string {.slot.} =
    result = self.delegate.markAllActivityCenterNotificationsRead()

  proc markAllActivityCenterNotificationsReadDone*(self: View) {.slot.} =
    self.model.markAllAsRead()

  proc markActivityCenterNotificationRead(self: View, notificationId: string): void {.slot.} =
    self.delegate.markActivityCenterNotificationRead(notificationId)

  proc markActivityCenterNotificationReadDone*(self: View, notificationId: string) =
    self.model.markActivityCenterNotificationRead(notificationId)

  proc markActivityCenterNotificationUnreadDone*(self: View, notificationId: string) =
    self.model.markActivityCenterNotificationUnread(notificationId)

  proc removeActivityCenterNotifications*(self: View, notificationIds: seq[string]) =
    self.model.removeNotifications(notificationIds)

  proc markActivityCenterNotificationUnread(self: View, notificationId: string): void {.slot.} =
    self.delegate.markActivityCenterNotificationUnread(notificationId)

  proc markAsSeenActivityCenterNotifications(self: View): void {.slot.} =
    self.delegate.markAsSeenActivityCenterNotifications()
    self.hasUnseenActivityCenterNotificationsChanged()

  proc addActivityCenterNotifications*(self: View, activityCenterNotifications: seq[Item]) =
    self.model.upsertActivityCenterNotifications(activityCenterNotifications)

  proc resetActivityCenterNotifications*(self: View, activityCenterNotifications: seq[Item]) =
    self.model.setNewData(activityCenterNotifications)

  proc switchTo*(self: View, sectionId: string, chatId: string, messageId: string) {.slot.} =
    self.delegate.switchTo(sectionId, chatId, messageId)

  proc getDetails*(self: View, sectionId: string, chatId: string): string {.slot.} =
    return self.delegate.getDetails(sectionId, chatId)

  proc getChatDetailsAsJson*(self: View, chatId: string): string {.slot.} =
    return self.delegate.getChatDetailsAsJson(chatId)

  proc activeNotificationGroupChanged*(self: View) {.signal.}

  proc setActiveNotificationGroup*(self: View, group: int) {.slot.} =
    self.delegate.setActiveNotificationGroup(group)
    self.activeNotificationGroupChanged()

  proc getActiveNotificationGroup*(self: View): int {.slot.} =
    return self.delegate.getActiveNotificationGroup()

  QtProperty[int] activeNotificationGroup:
    read = getActiveNotificationGroup
    write = setActiveNotificationGroup
    notify = activeNotificationGroupChanged

  proc activityCenterReadTypeChanged*(self: View) {.signal.}

  proc groupCountersChanged*(self: View) {.signal.}

  proc setActivityCenterReadType*(self: View, readType: int) {.slot.} =
    self.delegate.setActivityCenterReadType(readType)
    self.activityCenterReadTypeChanged()

  proc getActivityCenterReadType*(self: View): int {.slot.} =
    return self.delegate.getActivityCenterReadType()

  QtProperty[int] activityCenterReadType:
    read = getActivityCenterReadType
    write = setActivityCenterReadType
    notify = activityCenterReadTypeChanged

  proc getAdminCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.Admin, 0)

  QtProperty[int] adminCount:
    read = getAdminCount
    notify = groupCountersChanged

  proc getMentionsCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.Mentions, 0)

  QtProperty[int] mentionsCount:
    read = getMentionsCount
    notify = groupCountersChanged

  proc getRepliesCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.Replies, 0)

  QtProperty[int] repliesCount:
    read = getRepliesCount
    notify = groupCountersChanged

  proc getContactRequestsCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.ContactRequests, 0)

  QtProperty[int] contactRequestsCount:
    read = getContactRequestsCount
    notify = groupCountersChanged

  proc getIdentityVerificationCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.IdentityVerification, 0)

  QtProperty[int] identityVerificationCount:
    read = getIdentityVerificationCount
    notify = groupCountersChanged

  proc getMembershipCount*(self: View): int {.slot.} =
    return self.groupCounters.getOrDefault(ActivityCenterGroup.Membership, 0)

  QtProperty[int] membershipCount:
    read = getMembershipCount
    notify = groupCountersChanged

  proc setActivityGroupCounters*(self: View, counters: Table[ActivityCenterGroup, int]) =
    self.groupCounters = counters
    self.groupCountersChanged()
