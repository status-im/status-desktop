import Tables, stint
import ./controller_interface
import ./io_interface

import ../../../core/eventemitter
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/eth/utils as eth_utils

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    activityCenterService: activity_center_service.Service
    contactsService: contacts_service.Service
    messageService: message_service.Service

proc newController*[T](
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service
    ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.activityCenterService = activityCenterService
  result.contactsService = contactsService
  result.messageService = messageService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  self.events.on(activity_center_service.SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED) do(e: Args):
    let args = ActivityCenterNotificationsArgs(e)
    self.delegate.addActivityCenterNotification(args.activityCenterNotifications)

  self.events.on(activity_center_service.SIGNAL_MARK_NOTIFICATIONS_AS_ACCEPTED) do(e: Args):
    var evArgs = MarkAsAcceptedNotificationProperties(e)
    self.delegate.acceptActivityCenterNotificationsDone(evArgs.notificationIds)

  self.events.on(activity_center_service.SIGNAL_MARK_NOTIFICATIONS_AS_DISMISSED) do(e: Args):
    var evArgs = MarkAsDismissedNotificationProperties(e)
    self.delegate.dismissActivityCenterNotificationsDone(evArgs.notificationIds)

  self.events.on(activity_center_service.SIGNAL_MARK_NOTIFICATIONS_AS_READ) do(e: Args):
    var evArgs = MarkAsReadNotificationProperties(e)
    if (evArgs.isAll):
       self.delegate.markAllActivityCenterNotificationsReadDone()
       return
    if (evArgs.notificationIds.len > 0):
      self.delegate.markActivityCenterNotificationReadDone(evArgs.notificationIds)

  self.events.on(activity_center_service.SIGNAL_MARK_NOTIFICATIONS_AS_UNREAD) do(e: Args):
    var evArgs = MarkAsUnreadNotificationProperties(e)
    if (evArgs.notificationIds.len > 0):
      self.delegate.markActivityCenterNotificationUnreadDone(evArgs.notificationIds)


method hasMoreToShow*[T](self: Controller[T]): bool =
   return self.activityCenterService.hasMoreToShow()

method unreadActivityCenterNotificationsCount*[T](self: Controller[T]): int =
   return self.activityCenterService.unreadActivityCenterNotificationsCount()

method getContactDetails*[T](self: Controller[T], contactId: string): ContactDetails =
   return self.contactsService.getContactDetails(contactId)

method getActivityCenterNotifications*[T](self: Controller[T]): seq[ActivityCenterNotificationDto] =
   return self.activityCenterService.getActivityCenterNotifications()

method markAllActivityCenterNotificationsRead*[T](self: Controller[T]): string =
   return self.activityCenterService.markAllActivityCenterNotificationsRead()

method markActivityCenterNotificationRead*[T](
    self: Controller[T],
    notificationId: string,
    markAsReadProps: MarkAsReadNotificationProperties
    ): string =
   return self.activityCenterService.markActivityCenterNotificationRead(notificationId, markAsReadProps)

method markActivityCenterNotificationUnread*[T](
    self: Controller[T],
    notificationId: string,
    markAsUnreadProps: MarkAsUnreadNotificationProperties
    ): string =
   return self.activityCenterService.markActivityCenterNotificationUnread(notificationId, markAsUnreadProps)

method acceptActivityCenterNotifications*[T](self: Controller[T], notificationIds: seq[string]): string =
   return self.activityCenterService.acceptActivityCenterNotifications(notificationIds)

method dismissActivityCenterNotifications*[T](self: Controller[T], notificationIds: seq[string]): string =
   return self.activityCenterService.dismissActivityCenterNotifications(notificationIds)

method getRenderedText*[T](self: Controller[T], parsedTextArray: seq[ParsedText]): string =
  return self.messageService.getRenderedText(parsedTextArray)

method decodeContentHash*[T](self: Controller[T], hash: string): string =
  return eth_utils.decodeContentHash(hash)