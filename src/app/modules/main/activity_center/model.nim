import NimQml, Tables, chronicles, json, sequtils, strformat, strutils
import ./item

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
    Model* = ref object of QAbstractListModel
      activityCenterNotifications*: seq[Item]
      nbUnreadNotifications*: int

  proc setup(self: Model) = self.QAbstractListModel.setup

  proc delete(self: Model) =
    self.activityCenterNotifications = @[]
    self.QAbstractListModel.delete

  proc newModel*(): Model =
    new(result, delete)
    result.activityCenterNotifications = @[]
    result.setup()

  proc getUnreadNotificationsForChat*(self: Model, chatId: string): seq[string] =
    result =  @[]
    for notification in self.activityCenterNotifications:
      if (notification.chatId == chatId and not notification.read):
        result.add(notification.id)

  proc unreadCountChanged*(self: Model) {.signal.}

  proc unreadCount*(self: Model): int {.slot.}  =
    self.nbUnreadNotifications

  QtProperty[int] unreadCount:
    read = unreadCount
    notify = unreadCountChanged

  proc markAllAsRead*(self: Model)  =
    self.nbUnreadNotifications = 0
    self.unreadCountChanged()

    for activityCenterNotification in self.activityCenterNotifications:
      activityCenterNotification.read = true

    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.activityCenterNotifications.len - 1, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[NotifRoles.Read.int])

  method rowCount*(self: Model, index: QModelIndex = nil): int = self.activityCenterNotifications.len

  method data(self: Model, index: QModelIndex, role: int): QVariant =
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

  proc getNotificationData(self: Model, index: int, data: string): string {.slot.} =
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

  method roleNames(self: Model): Table[int, string] =
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

  proc reduceUnreadCount(self: Model, numberNotifs: int) =
    self.nbUnreadNotifications = self.nbUnreadNotifications - numberNotifs
    if (self.nbUnreadNotifications < 0):
      self.nbUnreadNotifications = 0
    self.unreadCountChanged()

  proc markActivityCenterNotificationUnread*(self: Model, notificationId: string) =
    self.nbUnreadNotifications = self.nbUnreadNotifications + 1
    self.unreadCountChanged()

    var i = 0
    for acnViewItem in self.activityCenterNotifications:
      if (acnViewItem.id == notificationId):
        acnViewItem.read = false
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[NotifRoles.Read.int])
        break
      i.inc

  proc markActivityCenterNotificationRead*(self: Model, notificationId: string) =
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
        break
      i.inc

  proc removeNotifications*(self: Model, ids: seq[string]) =
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

  proc setNewData*(self: Model, activityCenterNotifications: seq[Item]) =
    self.beginResetModel()
    self.activityCenterNotifications = activityCenterNotifications
    self.endResetModel()

  proc addActivityNotificationItemToList*(self: Model, activityCenterNotification: Item, addToCount: bool = true) =
    self.beginInsertRows(newQModelIndex(), self.activityCenterNotifications.len, self.activityCenterNotifications.len)

    self.activityCenterNotifications.add(activityCenterNotification)

    self.endInsertRows()

    if (addToCount and not activityCenterNotification.read):
      self.nbUnreadNotifications = self.nbUnreadNotifications + 1

  proc updateUnreadCount*(self: Model, count: int) =
    self.nbUnreadNotifications = count
    self.unreadCountChanged()

  proc addActivityNotificationItemsToList*(self: Model, activityCenterNotifications: seq[Item]) =
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
