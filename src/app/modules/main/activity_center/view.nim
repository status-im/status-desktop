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

  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.modelVariant)

  QtProperty[QVariant] model:
    read = getModel
    notify = activityNotificationsChanged
  
  proc hasMoreToShowChanged*(self: View) {.signal.}

  proc hasMoreToShow*(self: View): bool {.slot.}  =
    self.delegate.hasMoreToShow()

  QtProperty[bool] hasMoreToShow:
    read = hasMoreToShow
    notify = hasMoreToShowChanged

  proc pushActivityCenterNotifications*(self:View, activityCenterNotifications: seq[Item]) =
    self.model.addActivityNotificationItemsToList(activityCenterNotifications)
    self.activityNotificationsChanged()
    self.hasMoreToShowChanged()

    let count = self.delegate.unreadActivityCenterNotificationsCount()
    self.model.updateUnreadCount(count)

  proc loadMoreNotifications(self: View) {.slot.} =
    self.delegate.getActivityCenterNotifications()

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
    for activityCenterNotification in activityCenterNotifications:
      # TODO this should be handled by the chat or community module
      # if self.channelView.activeChannel.id == activityCenterNotification.chatId:
      #   activityCenterNotification.read = true
      #   let communityId = self.status.chat.getCommunityIdForChat(activityCenterNotification.chatId)
      #   if communityId != "":
      #     self.communities.joinedCommunityList.decrementMentions(communityId, activityCenterNotification.chatId)
      self.model.addActivityNotificationItemToList(activityCenterNotification)
    self.activityNotificationsChanged()
