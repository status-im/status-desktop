import NimQml, Tables, chronicles, json, sequtils, strformat
import status/status
import status/accounts
import status/types/[activity_center_notification]
import strutils
import message_item

type ActivityCenterNotificationViewItem* = ref object of ActivityCenterNotification
    messageItem*: MessageItem

type
  NotifRoles {.pure.} = enum
    Id = UserRole + 1
    ChatId = UserRole + 2
    Name = UserRole + 3
    NotificationType = UserRole + 4
    Message = UserRole + 5
    Timestamp = UserRole + 6
    Read = UserRole + 7
    Dismissed = UserRole + 8
    Accepted = UserRole + 9
    Author = UserRole + 10

QtObject:
  type
    ActivityNotificationList* = ref object of QAbstractListModel
      activityCenterNotifications*: seq[ActivityCenterNotificationViewItem]
      status: Status
      nbUnreadNotifications*: int

  proc setup(self: ActivityNotificationList) = self.QAbstractListModel.setup

  proc delete(self: ActivityNotificationList) = 
    self.activityCenterNotifications = @[]
    self.QAbstractListModel.delete

  proc newActivityNotificationList*(status: Status): ActivityNotificationList =
    new(result, delete)
    result.activityCenterNotifications = @[]
    result.status = status
    result.setup()

  proc unreadCountChanged*(self: ActivityNotificationList) {.signal.}

  proc unreadCount*(self: ActivityNotificationList): int {.slot.}  =
    self.nbUnreadNotifications

  QtProperty[int] unreadCount:
    read = unreadCount
    notify = unreadCountChanged

  proc hasMoreToShowChanged*(self: ActivityNotificationList) {.signal.}

  proc hasMoreToShow*(self: ActivityNotificationList): bool {.slot.}  =
    self.status.chat.activityCenterCursor != ""

  QtProperty[bool] hasMoreToShow:
    read = hasMoreToShow
    notify = hasMoreToShowChanged

  method rowCount*(self: ActivityNotificationList, index: QModelIndex = nil): int = self.activityCenterNotifications.len

  method data(self: ActivityNotificationList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.activityCenterNotifications.len:
      return

    let acitivityNotificationItem = self.activityCenterNotifications[index.row]
    let communityItemRole = role.NotifRoles
    case communityItemRole:
      of NotifRoles.Id: result = newQVariant(acitivityNotificationItem.id)
      of NotifRoles.ChatId: result = newQVariant(acitivityNotificationItem.chatId)
      of NotifRoles.Name: result = newQVariant(acitivityNotificationItem.name)
      of NotifRoles.Author: result = newQVariant(acitivityNotificationItem.author)
      of NotifRoles.NotificationType: result = newQVariant(acitivityNotificationItem.notificationType.int)
      of NotifRoles.Message: result = newQVariant(acitivityNotificationItem.messageItem)
      of NotifRoles.Timestamp: result = newQVariant(acitivityNotificationItem.timestamp)
      of NotifRoles.Read: result = newQVariant(acitivityNotificationItem.read.bool)
      of NotifRoles.Dismissed: result = newQVariant(acitivityNotificationItem.dismissed.bool)
      of NotifRoles.Accepted: result = newQVariant(acitivityNotificationItem.accepted.bool)

  proc getNotificationData(self: ActivityNotificationList, index: int, data: string): string {.slot.} =
    if index < 0 or index >= self.activityCenterNotifications.len: return ("")

    let notif = self.activityCenterNotifications[index]
    case data:
    of "id": result = notif.id
    of "chatId": result = notif.chatId
    of "name": result = notif.name
    of "author": result = notif.author
    of "notificationType": result = $(notif.notificationType.int)
    of "timestamp": result = $(notif.timestamp)
    of "read": result = $(notif.read)
    of "dismissed": result = $(notif.dismissed)
    of "accepted": result = $(notif.accepted)
    else: result = ("")

  method roleNames(self: ActivityNotificationList): Table[int, string] =
    {
      NotifRoles.Id.int:"id",
      NotifRoles.ChatId.int:"chatId",
      NotifRoles.Name.int: "name",
      NotifRoles.Author.int: "author",
      NotifRoles.NotificationType.int: "notificationType",
      NotifRoles.Message.int: "message",
      NotifRoles.Timestamp.int: "timestamp",
      NotifRoles.Read.int: "read",
      NotifRoles.Dismissed.int: "dismissed",
      NotifRoles.Accepted.int: "accepted"
    }.toTable

  proc loadMoreNotifications(self: ActivityNotificationList) {.slot.} =
    self.status.chat.activityCenterNotifications(false)
    self.hasMoreToShowChanged()

  proc markAllActivityCenterNotificationsRead(self: ActivityNotificationList): string {.slot.} =
    let error = self.status.chat.markAllActivityCenterNotificationsRead()
    if (error != ""):
      return error

    self.nbUnreadNotifications = 0
    self.unreadCountChanged()

    for activityCenterNotification in self.activityCenterNotifications:
      activityCenterNotification.read = true
    
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.activityCenterNotifications.len - 1, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[NotifRoles.Read.int])
  
  proc reduceUnreadCount(self: ActivityNotificationList, numberNotifs: int) =
    self.nbUnreadNotifications = self.nbUnreadNotifications - numberNotifs
    if (self.nbUnreadNotifications < 0):
      self.nbUnreadNotifications = 0
    self.unreadCountChanged()

  proc markActivityCenterNotificationRead(self: ActivityNotificationList, notificationId: string,
  communityId: string, channelId: string, nType: int): void {.slot.} =

    let notificationType = ActivityCenterNotificationType(nType)
    let markAsReadProps = MarkAsReadNotificationProperties(communityId: communityId,
    channelId: channelId, notificationTypes: @[notificationType])

    let error = self.status.chat.markActivityCenterNotificationRead(notificationId, markAsReadProps)
    if (error != ""):
      return
    
    self.nbUnreadNotifications = self.nbUnreadNotifications - 1
    if (self.nbUnreadNotifications < 0):
      self.nbUnreadNotifications = 0
    self.unreadCountChanged()

    var i = 0
    for acnViewItem in self.activityCenterNotifications:
      if (acnViewItem.id == notificationId):
        acnViewItem.read = true
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[NotifRoles.Read.int])
      i.inc

  proc removeNotifications(self: ActivityNotificationList, ids: seq[string]) =
    var i = 0
    var indexesToDelete: seq[int] = @[]
    for activityCenterNotification in self.activityCenterNotifications:
      for id in ids:
        if (activityCenterNotification.id == id):
          indexesToDelete.add(i)
          break
      i = i + 1
    
    i = 0
    for index in indexesToDelete:
      let indexUpdated = index - i
      self.beginRemoveRows(newQModelIndex(), indexUpdated, indexUpdated)
      self.activityCenterNotifications.delete(indexUpdated)
      self.endRemoveRows()
      i = i + 1

    self.reduceUnreadCount(ids.len)

  proc acceptActivityCenterNotifications(self: ActivityNotificationList, idsJson: string): string {.slot.} =
    let ids = map(parseJson(idsJson).getElems(), proc(x:JsonNode):string = x.getStr())

    let error = self.status.chat.acceptActivityCenterNotifications(ids)
    if (error != ""):
      return error

    self.removeNotifications(ids)

  proc acceptActivityCenterNotification(self: ActivityNotificationList, id: string): string {.slot.} =
    self.acceptActivityCenterNotifications(fmt"[""{id}""]")

  proc dismissActivityCenterNotifications(self: ActivityNotificationList, idsJson: string): string {.slot.} =
    let ids = map(parseJson(idsJson).getElems(), proc(x:JsonNode):string = x.getStr())

    let error = self.status.chat.dismissActivityCenterNotifications(ids)
    if (error != ""):
      return error

    self.removeNotifications(ids)

  proc dismissActivityCenterNotification(self: ActivityNotificationList, id: string): string {.slot.} =
    self.dismissActivityCenterNotifications(fmt"[""{id}""]")

  proc toActivityCenterNotificationViewItem*(self: ActivityNotificationList, activityCenterNotification: ActivityCenterNotification): ActivityCenterNotificationViewItem =
    let communityId = self.status.chat.getCommunityIdForChat(activityCenterNotification.chatId)
    activityCenterNotification.message.communityId = communityId
    ActivityCenterNotificationViewItem(
          id: activityCenterNotification.id,
          chatId: activityCenterNotification.chatId,
          name: activityCenterNotification.name,
          notificationType: activityCenterNotification.notificationType,
          author: activityCenterNotification.author,
          timestamp: activityCenterNotification.timestamp,
          read: activityCenterNotification.read,
          dismissed: activityCenterNotification.dismissed,
          accepted: activityCenterNotification.accepted,
          messageItem: newMessageItem(self.status, activityCenterNotification.message)
        )

  proc setNewData*(self: ActivityNotificationList, activityCenterNotifications: seq[ActivityCenterNotification]) =
    self.beginResetModel()
    self.activityCenterNotifications = @[]
    
    for activityCenterNotification in activityCenterNotifications:
      self.activityCenterNotifications.add(self.toActivityCenterNotificationViewItem(activityCenterNotification))
 
    self.endResetModel()

  proc addActivityNotificationItemToList*(self: ActivityNotificationList, activityCenterNotification: ActivityCenterNotification, addToCount: bool = true) =
    self.beginInsertRows(newQModelIndex(), self.activityCenterNotifications.len, self.activityCenterNotifications.len)

    self.activityCenterNotifications.add(self.toActivityCenterNotificationViewItem(activityCenterNotification))

    self.endInsertRows()

    if (addToCount and not activityCenterNotification.read):
      self.nbUnreadNotifications = self.nbUnreadNotifications + 1

  proc addActivityNotificationItemsToList*(self: ActivityNotificationList, activityCenterNotifications: seq[ActivityCenterNotification]) =
    if (self.activityCenterNotifications.len == 0):
      self.setNewData(activityCenterNotifications)
    else:
      for activityCenterNotification in activityCenterNotifications:
        var found = false
        for notif in self.activityCenterNotifications:
          if activityCenterNotification.id == notif.id:
            found = true
            break
        if found: continue
        self.addActivityNotificationItemToList(activityCenterNotification, false)

    self.nbUnreadNotifications = self.status.chat.unreadActivityCenterNotificationsCount()
    self.unreadCountChanged()
    self.hasMoreToShowChanged()
