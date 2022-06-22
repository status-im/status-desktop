import Tables, stint
import ./io_interface

import ../../../global/app_signals
import ../../../core/eventemitter
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/eth/utils as eth_utils
import ../../../../app_service/service/chat/service as chat_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    activityCenterService: activity_center_service.Service
    contactsService: contacts_service.Service
    messageService: message_service.Service
    chatService: chat_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service,
    chatService: chat_service.Service
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.activityCenterService = activityCenterService
  result.contactsService = contactsService
  result.messageService = messageService
  result.chatService = chatService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
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


proc hasMoreToShow*(self: Controller): bool =
   return self.activityCenterService.hasMoreToShow()

proc unreadActivityCenterNotificationsCount*(self: Controller): int =
   return self.activityCenterService.unreadActivityCenterNotificationsCount()

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
   return self.contactsService.getContactDetails(contactId)

proc getActivityCenterNotifications*(self: Controller): seq[ActivityCenterNotificationDto] =
   return self.activityCenterService.getActivityCenterNotifications()

proc markAllActivityCenterNotificationsRead*(self: Controller): string =
   return self.activityCenterService.markAllActivityCenterNotificationsRead()

proc markActivityCenterNotificationRead*(
    self: Controller,
    notificationId: string,
    markAsReadProps: MarkAsReadNotificationProperties
    ): string =
   return self.activityCenterService.markActivityCenterNotificationRead(notificationId, markAsReadProps)

proc markActivityCenterNotificationUnread*(
    self: Controller,
    notificationId: string,
    markAsUnreadProps: MarkAsUnreadNotificationProperties
    ): string =
   return self.activityCenterService.markActivityCenterNotificationUnread(notificationId, markAsUnreadProps)

proc acceptActivityCenterNotifications*(self: Controller, notificationIds: seq[string]): string =
   return self.activityCenterService.acceptActivityCenterNotifications(notificationIds)

proc dismissActivityCenterNotifications*(self: Controller, notificationIds: seq[string]): string =
   return self.activityCenterService.dismissActivityCenterNotifications(notificationIds)

proc getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText]): string =
  return self.messageService.getRenderedText(parsedTextArray)

proc decodeContentHash*(self: Controller, hash: string): string =
  return eth_utils.decodeContentHash(hash)

proc switchTo*(self: Controller, sectionId, chatId, messageId: string) =
  let data = ActiveSectionChatArgs(sectionId: sectionId, chatId: chatId, messageId: messageId)
  self.events.emit(SIGNAL_MAKE_SECTION_CHAT_ACTIVE, data)

proc getChatDetails*(self: Controller, chatId: string): ChatDto =
  return self.chatService.getChatById(chatId)

proc getChannelGroups*(self: Controller): seq[ChannelGroupDto] =
  return self.chatService.getChannelGroups()

proc getOneToOneChatNameAndImage*(self: Controller, chatId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)

proc getMessageById*(self: Controller, chatId, messageId: string): MessageDto =
  let (message, _, err) = self.messageService.getDetailsForMessage(chatId, messageId)
  if(err.len > 0):
    return MessageDto()
  return message