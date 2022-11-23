import NimQml, json, strutils, json_serialization, sequtils, strformat
import ../../../../app_service/service/activity_center/service as activity_center_service

import ./model
import ./io_interface, ./item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

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

  proc pushActivityCenterNotifications*(self:View, activityCenterNotifications: seq[Item]) =
    self.model.addActivityNotificationItemsToList(activityCenterNotifications)
    self.hasMoreToShowChanged()

  proc loadMoreNotifications(self: View) {.slot.} =
    self.delegate.fetchActivityCenterNotifications()

  proc markAllActivityCenterNotificationsRead(self: View): string {.slot.} =
    result = self.delegate.markAllActivityCenterNotificationsRead()

  proc markAllActivityCenterNotificationsReadDone*(self: View) {.slot.} =
    self.model.markAllAsRead()

  proc markActivityCenterNotificationRead(
      self: View,
      notificationId: string,
      communityId: string,
      channelId: string,
      nType: int
      ): void {.slot.} =
    discard self.delegate.markActivityCenterNotificationRead(notificationId, communityId, channelId, nType)

  proc markActivityCenterNotificationReadDone*(self: View, notificationId: string) =
     self.model.markActivityCenterNotificationRead(notificationId)

  proc markActivityCenterNotificationUnreadDone*(self: View, notificationId: string) =
     self.model.markActivityCenterNotificationUnread(notificationId)

  proc markAllChatMentionsAsRead*(self: View, communityId: string, chatId: string) =
    let notifsIds = self.model.getUnreadNotificationsForChat(chatId)
    for notifId in notifsIds:
      # TODO change the 3 to the real type
      self.markActivityCenterNotificationRead(notifId, communityId, chatId, ActivityCenterNotificationType.Mention.int)

  proc markActivityCenterNotificationUnread(
      self: View,
      notificationId: string,
      communityId: string,
      channelId: string,
      nType: int
      ): void {.slot.} =
    discard self.delegate.markActivityCenterNotificationUnread(
      notificationId,
      communityId,
      channelId,
      nType
    )

  proc acceptActivityCenterNotifications(self: View, idsJson: string): string {.slot.} =
    let ids = map(parseJson(idsJson).getElems(), proc(x:JsonNode):string = x.getStr())

    result = self.delegate.acceptActivityCenterNotifications(ids)

  proc acceptActivityCenterNotificationsDone*(self: View, notificationIds: seq[string]) =
    self.model.removeNotifications(notificationIds)

  proc acceptActivityCenterNotification(self: View, id: string): string {.slot.} =
    self.acceptActivityCenterNotifications(fmt"[""{id}""]")

  proc dismissActivityCenterNotifications(self: View, idsJson: string): string {.slot.} =
    let ids = map(parseJson(idsJson).getElems(), proc(x:JsonNode):string = x.getStr())

    result = self.delegate.dismissActivityCenterNotifications(ids)

  proc dismissActivityCenterNotification(self: View, id: string): string {.slot.} =
    self.dismissActivityCenterNotifications(fmt"[""{id}""]")

  proc dismissActivityCenterNotificationsDone*(self: View, notificationIds: seq[string]) =
    self.model.removeNotifications(notificationIds)

  proc addActivityCenterNotification*(self: View, activityCenterNotifications: seq[Item]) =
    self.model.addActivityNotificationItemsToList(activityCenterNotifications)

  proc switchTo*(self: View, sectionId: string, chatId: string, messageId: string) {.slot.} =
    self.delegate.switchTo(sectionId, chatId, messageId)

  proc getDetails*(self: View, sectionId: string, chatId: string): string {.slot.} =
    return self.delegate.getDetails(sectionId, chatId)

  proc getChatDetailsAsJson*(self: View, chatId: string): string {.slot.} =
    return self.delegate.getChatDetailsAsJson(chatId)