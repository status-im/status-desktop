import NimQml, Tables, chronicles
import ../../../status/chat/chat
import ../../../status/status
import ../../../status/accounts
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
      NotifRoles.NotificationType.int: "notificationType",
      NotifRoles.Message.int: "message",
      NotifRoles.Timestamp.int: "timestamp",
      NotifRoles.Read.int: "read",
      NotifRoles.Dismissed.int: "dismissed",
      NotifRoles.Accepted.int: "accepted"
    }.toTable

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


  proc toActivityCenterNotificationViewItem*(self: ActivityNotificationList, activityCenterNotification: ActivityCenterNotification): ActivityCenterNotificationViewItem =
    ActivityCenterNotificationViewItem(
          id: activityCenterNotification.id,
          chatId: activityCenterNotification.chatId,
          name: activityCenterNotification.name,
          notificationType: activityCenterNotification.notificationType,
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

    self.nbUnreadNotifications = self.status.chat.unreadActivityCenterNotificationsCount()
    self.unreadCountChanged()

  proc addActivityNotificationItemToList*(self: ActivityNotificationList, activityCenterNotification: ActivityCenterNotification) =
    self.beginInsertRows(newQModelIndex(), self.activityCenterNotifications.len, self.activityCenterNotifications.len)

    self.activityCenterNotifications.add(self.toActivityCenterNotificationViewItem(activityCenterNotification))

    self.endInsertRows()

    if (not activityCenterNotification.read):
      self.nbUnreadNotifications = self.nbUnreadNotifications + 1