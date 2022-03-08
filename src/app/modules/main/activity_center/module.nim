import NimQml, Tables, stint, sugar, sequtils

import ./io_interface, ./view, ./controller
import ./item as notification_item
import ../../shared_models/message_item as msg_item
import ../../shared_models/message_item_qobject as msg_item_qobj
import ../../shared_models/message_transaction_parameters_item
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/chat/service as chat_service

import ../../../global/app_sections_config as conf

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](
    delegate: T,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service,
    chatService: chat_service.Service
    ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](
    result,
    events,
    activityCenterService,
    contactsService,
    messageService,
    chatService
  )
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("activityCenterModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method viewDidLoad*[T](self: Module[T]) =
  self.moduleLoaded = true
  self.delegate.activityCenterDidLoad()

method hasMoreToShow*[T](self: Module[T]): bool =
  self.controller.hasMoreToShow()

method unreadActivityCenterNotificationsCount*[T](self: Module[T]): int =
  self.controller.unreadActivityCenterNotificationsCount()

method convertToItems*[T](
  self: Module[T],
  activityCenterNotifications: seq[ActivityCenterNotificationDto]
  ): seq[notification_item.Item] =
  result = activityCenterNotifications.map(
    proc(n: ActivityCenterNotificationDto): notification_item.Item =
      var messageItem =  msg_item_qobj.newMessageItem(nil)

      let chatDetails = self.controller.getChatDetails(n.chatId)
      # default section id is `Chat` section
      let sectionId = if(chatDetails.communityId.len > 0): chatDetails.communityId else: conf.CHAT_SECTION_ID

      if (n.message.id != ""):
        # If there is a message in the Notification, transfer it to a MessageItem (QObject)
        let contactDetails = self.controller.getContactDetails(n.message.`from`)
        messageItem = msg_item_qobj.newMessageItem(msg_item.initItem(
          n.message.id,
          chatDetails.communityId, # we don't received community id via `activityCenterNotifications` api call
          n.message.responseTo,
          n.message.`from`,
          contactDetails.displayName,
          contactDetails.details.localNickname,
          contactDetails.icon,
          contactDetails.isIdenticon,
          contactDetails.isCurrentUser,
          n.message.outgoingStatus,
          self.controller.getRenderedText(n.message.parsedText),
          n.message.image,
          n.message.containsContactMentions(),
          n.message.seen,
          n.message.timestamp,
          ContentType(n.message.contentType),
          n.message.messageType,
          self.controller.decodeContentHash(n.message.sticker.hash),
          n.message.sticker.pack,
          n.message.links,
          newTransactionParametersItem("","","","","","",-1,""),
        ))

      return notification_item.initItem(
        n.id,
        n.chatId,
        sectionId,
        n.name,
        n.author,
        n.notificationType.int,
        n.timestamp,
        n.read,
        n.dismissed,
        n.accepted,
        messageItem
      )
    )

method getActivityCenterNotifications*[T](self: Module[T]): seq[notification_item.Item] =
  let activityCenterNotifications = self.controller.getActivityCenterNotifications()
  self.view.pushActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method markAllActivityCenterNotificationsRead*[T](self: Module[T]): string =
  self.controller.markAllActivityCenterNotificationsRead()

method markAllActivityCenterNotificationsReadDone*[T](self: Module[T]) =
  self.view.markAllActivityCenterNotificationsReadDone()

method markActivityCenterNotificationRead*[T](
    self: Module[T],
    notificationId: string,
    communityId: string,
    channelId: string,
    nType: int
    ): string =
  let notificationType = ActivityCenterNotificationType(nType)
  let markAsReadProps = MarkAsReadNotificationProperties(
    notificationIds: @[notificationId],
    communityId: communityId,
    channelId: channelId,
    notificationTypes: @[notificationType]
  )
  result = self.controller.markActivityCenterNotificationRead(notificationId, markAsReadProps)

method markActivityCenterNotificationReadDone*[T](self: Module[T], notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationReadDone(notificationId)

method pushActivityCenterNotifications*[T](
    self: Module[T],
    activityCenterNotifications: seq[ActivityCenterNotificationDto]
    ) =
  self.view.pushActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method addActivityCenterNotification*[T](
    self: Module[T],
    activityCenterNotifications: seq[ActivityCenterNotificationDto]
    ) =
  self.view.addActivityCenterNotification(self.convertToItems(activityCenterNotifications))

method markActivityCenterNotificationUnread*[T](
    self: Module[T],
    notificationId: string,
    communityId: string,
    channelId: string,
    nType: int
    ): string =
  let notificationType = ActivityCenterNotificationType(nType)
  let markAsUnreadProps = MarkAsUnreadNotificationProperties(
    notificationIds: @[notificationId],
    communityId: communityId,
    channelId: channelId,
    notificationTypes: @[notificationType]
  )

  result = self.controller.markActivityCenterNotificationUnread(notificationId, markAsUnreadProps)

method markActivityCenterNotificationUnreadDone*[T](self: Module[T], notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationUnreadDone(notificationId)

method acceptActivityCenterNotificationsDone*[T](self: Module[T], notificationIds: seq[string]) =
  self.view.acceptActivityCenterNotificationsDone(notificationIds)

method acceptActivityCenterNotifications*[T](self: Module[T], notificationIds: seq[string]): string =
  self.controller.acceptActivityCenterNotifications(notificationIds)

method dismissActivityCenterNotificationsDone*[T](self: Module[T], notificationIds: seq[string]) =
  self.view.dismissActivityCenterNotificationsDone(notificationIds)

method dismissActivityCenterNotifications*[T](self: Module[T], notificationIds: seq[string]): string =
  self.controller.dismissActivityCenterNotifications(notificationIds)

method switchTo*[T](self: Module[T], sectionId, chatId, messageId: string) =
  self.controller.switchTo(sectionId, chatId, messageId)
