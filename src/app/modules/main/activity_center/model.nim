import NimQml, Tables, chronicles, json, sequtils, strformat, strutils
import ./item

type
  NotifRoles {.pure.} = enum
    Id = UserRole + 1
    ChatId
    CommunityId
    MembershipStatus
    VerificationStatus
    SectionId
    Name
    NotificationType
    Message
    Timestamp
    PreviousTimestamp
    Read
    Dismissed
    Accepted
    Author
    RepliedMessage
    ChatType

QtObject:
  type
    Model* = ref object of QAbstractListModel
      activityCenterNotifications*: seq[Item]

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

  proc markAllAsRead*(self: Model)  =
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

    let activityNotificationItem = self.activityCenterNotifications[index.row]
    let notificationItemRole = role.NotifRoles
    case notificationItemRole:
      of NotifRoles.Id: result = newQVariant(activityNotificationItem.id)
      of NotifRoles.ChatId: result = newQVariant(activityNotificationItem.chatId)
      of NotifRoles.CommunityId: result = newQVariant(activityNotificationItem.communityId)
      of NotifRoles.MembershipStatus: result = newQVariant(activityNotificationItem.membershipStatus.int)
      of NotifRoles.VerificationStatus: result = newQVariant(activityNotificationItem.verificationStatus.int)
      of NotifRoles.SectionId: result = newQVariant(activityNotificationItem.sectionId)
      of NotifRoles.Name: result = newQVariant(activityNotificationItem.name)
      of NotifRoles.Author: result = newQVariant(activityNotificationItem.author)
      of NotifRoles.NotificationType: result = newQVariant(activityNotificationItem.notificationType.int)
      of NotifRoles.Message: result = newQVariant(activityNotificationItem.messageItem)
      of NotifRoles.Timestamp: result = newQVariant(activityNotificationItem.timestamp)
      of NotifRoles.PreviousTimestamp: result = newQVariant(if index.row > 0:
                                                              self.activityCenterNotifications[index.row - 1].timestamp
                                                            else:
                                                              0)
      of NotifRoles.Read: result = newQVariant(activityNotificationItem.read.bool)
      of NotifRoles.Dismissed: result = newQVariant(activityNotificationItem.dismissed.bool)
      of NotifRoles.Accepted: result = newQVariant(activityNotificationItem.accepted.bool)
      of NotifRoles.RepliedMessage: result = newQVariant(activityNotificationItem.repliedMessageItem)
      of NotifRoles.ChatType: result = newQVariant(activityNotificationItem.chatType.int)

  method roleNames(self: Model): Table[int, string] =
    {
      NotifRoles.Id.int:"id",
      NotifRoles.ChatId.int:"chatId",
      NotifRoles.CommunityId.int:"communityId",
      NotifRoles.MembershipStatus.int: "membershipStatus",
      NotifRoles.VerificationStatus.int: "verificationStatus",
      NotifRoles.SectionId.int: "sectionId",
      NotifRoles.Name.int: "name",
      NotifRoles.Author.int: "author",
      NotifRoles.NotificationType.int: "notificationType",
      NotifRoles.Message.int: "message",
      NotifRoles.Timestamp.int: "timestamp",
      NotifRoles.PreviousTimestamp.int: "previousTimestamp",
      NotifRoles.Read.int: "read",
      NotifRoles.Dismissed.int: "dismissed",
      NotifRoles.Accepted.int: "accepted",
      NotifRoles.RepliedMessage.int: "repliedMessage",
      NotifRoles.ChatType.int: "chatType"
    }.toTable

  proc markActivityCenterNotificationUnread*(self: Model, notificationId: string) =
    var i = 0
    for acnViewItem in self.activityCenterNotifications:
      if (acnViewItem.id == notificationId):
        acnViewItem.read = false
        let index = self.createIndex(i, 0, nil)
        self.dataChanged(index, index, @[NotifRoles.Read.int])
        break
      i.inc

  proc markActivityCenterNotificationRead*(self: Model, notificationId: string) =
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

  proc setNewData*(self: Model, activityCenterNotifications: seq[Item]) =
    self.beginResetModel()
    self.activityCenterNotifications = activityCenterNotifications
    self.endResetModel()

  proc addActivityNotificationItemToList*(self: Model, activityCenterNotification: Item, addToCount: bool = true) =
    self.beginInsertRows(newQModelIndex(), 0, 0)
    self.activityCenterNotifications.insert(activityCenterNotification, 0)
    self.endInsertRows()

    if self.activityCenterNotifications.len > 1:
      let topLeft = self.createIndex(0, 0, nil)
      let bottomRight = self.createIndex(1, 0, nil)
      self.dataChanged(topLeft, bottomRight, @[NotifRoles.Timestamp.int, NotifRoles.PreviousTimestamp.int])

  proc addActivityNotificationItemsToList*(self: Model, activityCenterNotifications: seq[Item]) =
    if self.activityCenterNotifications.len == 0:
      self.setNewData(activityCenterNotifications)
    else:
      for activityCenterNotification in activityCenterNotifications:
        for notif in self.activityCenterNotifications:
          if activityCenterNotification.id == notif.id:
            self.removeNotifications(@[notif.id])
            break
        self.addActivityNotificationItemToList(activityCenterNotification, false)
