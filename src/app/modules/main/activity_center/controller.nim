import Tables, stint
import ./io_interface

import ../../../global/app_signals
import ../../../core/eventemitter
import ../../../../app_service/service/activity_center/service as activity_center_service
import ../../../../app_service/service/contacts/service as contacts_service
import ../../../../app_service/service/message/service as message_service
import ../../../../app_service/service/community/service as community_service
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
    communityService: community_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.activityCenterService = activityCenterService
  result.contactsService = contactsService
  result.messageService = messageService
  result.chatService = chatService
  result.communityService = communityService

proc delete*(self: Controller) =
  discard

proc updateActivityGroupCounters*(self: Controller) =
  let counters = self.activityCenterService.getActivityGroupCounters()
  self.delegate.setActivityGroupCounters(counters)

proc init*(self: Controller) =
  self.events.once(chat_service.SIGNAL_CHANNEL_GROUPS_LOADED) do(e:Args):
    # Only fectch activity center notification once channel groups are loaded,
    # since we need the chats to associate the notifications to
    self.activity_center_service.asyncActivityNotificationLoad()

  self.events.on(activity_center_service.SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED) do(e: Args):
    let args = ActivityCenterNotificationsArgs(e)
    self.delegate.addActivityCenterNotifications(args.activityCenterNotifications)

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

  self.events.on(activity_center_service.SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED) do(e: Args):
    self.delegate.unreadActivityCenterNotificationsCountChanged()
    self.delegate.hasUnseenActivityCenterNotificationsChanged()
    self.updateActivityGroupCounters()

  self.events.on(activity_center_service.SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_REMOVED) do(e: Args):
    var evArgs = RemoveActivityCenterNotificationsArgs(e)
    if (evArgs.notificationIds.len > 0):
      self.delegate.removeActivityCenterNotifications(evArgs.notificationIds)

proc hasMoreToShow*(self: Controller): bool =
   return self.activityCenterService.hasMoreToShow()

proc unreadActivityCenterNotificationsCount*(self: Controller): int =
   return self.activityCenterService.getUnreadActivityCenterNotificationsCount()

proc hasUnseenActivityCenterNotifications*(self: Controller): bool =
   return self.activityCenterService.getHasUnseenActivityCenterNotifications()

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
   return self.contactsService.getContactDetails(contactId)

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

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

proc markAsSeenActivityCenterNotifications*(self: Controller) =
   self.activityCenterService.markAsSeenActivityCenterNotifications()

proc acceptActivityCenterNotifications*(self: Controller, notificationIds: seq[string]): string =
   return self.activityCenterService.acceptActivityCenterNotifications(notificationIds)

proc dismissActivityCenterNotifications*(self: Controller, notificationIds: seq[string]): string =
   return self.activityCenterService.dismissActivityCenterNotifications(notificationIds)

proc replacePubKeysWithDisplayNames*(self: Controller, message: string): string =
  return self.messageService.replacePubKeysWithDisplayNames(message)

proc getRenderedText*(self: Controller, parsedTextArray: seq[ParsedText], communityChats: seq[ChatDto]): string =
  return self.messageService.getRenderedText(parsedTextArray, communityChats)

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

proc setActiveNotificationGroup*(self: Controller, group: ActivityCenterGroup) =
  self.activityCenterService.setActiveNotificationGroup(group)
  self.activityCenterService.resetCursor()
  let activityCenterNotifications = self.activityCenterService.getActivityCenterNotifications()
  self.delegate.resetActivityCenterNotifications(activityCenterNotifications)

proc getActiveNotificationGroup*(self: Controller): ActivityCenterGroup =
  return self.activityCenterService.getActiveNotificationGroup()

proc setActivityCenterReadType*(self: Controller, readType: ActivityCenterReadType) =
  self.activityCenterService.setActivityCenterReadType(readType)
  self.activityCenterService.resetCursor()
  let activityCenterNotifications = self.activityCenterService.getActivityCenterNotifications()
  self.delegate.resetActivityCenterNotifications(activityCenterNotifications)
  self.updateActivityGroupCounters()

proc getActivityCenterReadType*(self: Controller): ActivityCenterReadType =
  return self.activityCenterService.getActivityCenterReadType()

