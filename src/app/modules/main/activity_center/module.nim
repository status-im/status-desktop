import NimQml, Tables, json, stint, sugar, sequtils

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
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
import ../../../../app_service/service/community/service as community_service

import ../../../global/app_sections_config as conf

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    activityCenterService: activity_center_service.Service,
    contactsService: contacts_service.Service,
    messageService: message_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    activityCenterService,
    contactsService,
    messageService,
    chatService,
    communityService
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("activityCenterModule", self.viewVariant)
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.activityCenterDidLoad()

method hasMoreToShow*(self: Module): bool =
  self.controller.hasMoreToShow()

method unreadActivityCenterNotificationsCount*(self: Module): int =
  self.controller.unreadActivityCenterNotificationsCount()

method hasUnseenActivityCenterNotifications*(self: Module): bool =
  self.controller.hasUnseenActivityCenterNotifications()

method unreadActivityCenterNotificationsCountChanged*(self: Module) =
  self.view.unreadActivityCenterNotificationsCountChanged()

method hasUnseenActivityCenterNotificationsChanged*(self: Module) =
  self.view.hasUnseenActivityCenterNotificationsChanged()

proc createMessageItemFromDto(self: Module, message: MessageDto, communityId: string): MessageItem =
  let contactDetails = self.controller.getContactDetails(message.`from`)
  let communityChats = self.controller.getCommunityById(communityId).chats

  var quotedMessageAuthorDetails = ContactDetails()
  if message.quotedMessage.`from` != "":
    if(message.`from` == message.quotedMessage.`from`):
      quotedMessageAuthorDetails = contactDetails
    else:
      quotedMessageAuthorDetails = self.controller.getContactDetails(message.quotedMessage.`from`)

  return msg_item_qobj.newMessageItem(msg_item.initItem(
    message.id,
    communityId, # we don't received community id via `activityCenterNotifications` api call
    message.responseTo,
    message.`from`,
    contactDetails.defaultDisplayName,
    contactDetails.optionalName,
    contactDetails.icon,
    contactDetails.colorHash,
    contactDetails.isCurrentUser,
    contactDetails.dto.added,
    message.outgoingStatus,
    self.controller.getRenderedText(message.parsedText, communityChats),
    self.controller.replacePubKeysWithDisplayNames(message.text),
    message.parsedText,
    message.image,
    message.containsContactMentions(),
    message.seen,
    timestamp = message.timestamp,
    clock = message.clock,
    message.contentType,
    message.messageType,
    message.contactRequestState,
    message.sticker.url,
    message.sticker.pack,
    message.links,
    message.linkPreviews,
    newTransactionParametersItem("","","","","","",-1,""),
    message.mentionedUsersPks,
    contactDetails.dto.trustStatus,
    contactDetails.dto.ensVerified,
    message.discordMessage,
    resendError = "",
    message.mentioned,
    message.quotedMessage.`from`,
    message.quotedMessage.text,
    self.controller.getRenderedText(message.quotedMessage.parsedText, communityChats),
    message.quotedMessage.contentType,
    message.quotedMessage.deleted,
    message.quotedMessage.discordMessage,
    quotedMessageAuthorDetails,
    message.albumId,
    if (len(message.albumId) == 0): @[] else: @[message.image],
    if (len(message.albumId) == 0): @[] else: @[message.id],
    message.albumImagesCount,
    ))

method convertToItems*(
    self: Module,
    activityCenterNotifications: seq[ActivityCenterNotificationDto]
    ): seq[notification_item.Item] =
  result = activityCenterNotifications.map(
    proc(notification: ActivityCenterNotificationDto): notification_item.Item =
      var messageItem: MessageItem
      var repliedMessageItem: MessageItem
      # default section id is `Chat` section
      let sectionId = if notification.communityId.len > 0:
          notification.communityId
        else:
          singletonInstance.userProfile.getPubKey()

      if (notification.message.id != ""):
        let communityId = sectionId
        # If there is a message in the Notification, transfer it to a MessageItem (QObject)
        messageItem = self.createMessageItemFromDto(notification.message, communityId)

        if (notification.notificationType == ActivityCenterNotificationType.Reply and notification.message.responseTo != ""):
          repliedMessageItem = self.createMessageItemFromDto(notification.replyMessage, communityId)

        if (notification.notificationType == ActivityCenterNotificationType.ContactVerification):
          repliedMessageItem = self.createMessageItemFromDto(notification.replyMessage, communityId)

      return notification_item.initItem(
        notification.id,
        notification.chatId,
        notification.communityId,
        notification.membershipStatus,
        notification.verificationStatus,
        sectionId,
        notification.name,
        notification.author,
        notification.notificationType,
        notification.timestamp,
        notification.read,
        notification.dismissed,
        notification.accepted,
        messageItem,
        repliedMessageItem,
        ChatType.Unknown # TODO: should use correct chat type
      )
    )

method fetchActivityCenterNotifications*(self: Module) =
  let activityCenterNotifications = self.controller.getActivityCenterNotifications()
  self.view.addActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method markAllActivityCenterNotificationsRead*(self: Module): string =
  self.controller.markAllActivityCenterNotificationsRead()

method markAllActivityCenterNotificationsReadDone*(self: Module) =
  self.view.markAllActivityCenterNotificationsReadDone()

method markActivityCenterNotificationRead*(
    self: Module,
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

method markActivityCenterNotificationReadDone*(self: Module, notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationReadDone(notificationId)

method markAsSeenActivityCenterNotifications*(self: Module) =
  self.controller.markAsSeenActivityCenterNotifications()

method addActivityCenterNotifications*(self: Module, activityCenterNotifications: seq[ActivityCenterNotificationDto]) =
  self.view.addActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method resetActivityCenterNotifications*(self: Module, activityCenterNotifications: seq[ActivityCenterNotificationDto]) =
  self.view.resetActivityCenterNotifications(self.convertToItems(activityCenterNotifications))

method markActivityCenterNotificationUnread*(
    self: Module,
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

method markActivityCenterNotificationUnreadDone*(self: Module, notificationIds: seq[string]) =
  for notificationId in notificationIds:
    self.view.markActivityCenterNotificationUnreadDone(notificationId)

method removeActivityCenterNotifications*(self: Module, notificationIds: seq[string]) =
  self.view.removeActivityCenterNotifications(notificationIds)

method acceptActivityCenterNotificationsDone*(self: Module, notificationIds: seq[string]) =
  self.view.acceptActivityCenterNotificationsDone(notificationIds)

method acceptActivityCenterNotifications*(self: Module, notificationIds: seq[string]): string =
  self.controller.acceptActivityCenterNotifications(notificationIds)

method dismissActivityCenterNotificationsDone*(self: Module, notificationIds: seq[string]) =
  self.view.dismissActivityCenterNotificationsDone(notificationIds)

method dismissActivityCenterNotifications*(self: Module, notificationIds: seq[string]): string =
  self.controller.dismissActivityCenterNotifications(notificationIds)

method switchTo*(self: Module, sectionId, chatId, messageId: string) =
  self.controller.switchTo(sectionId, chatId, messageId)

method getDetails*(self: Module, sectionId: string, chatId: string): string =
  let groups = self.controller.getChannelGroups()
  var jsonObject = newJObject()

  for g in groups:
    if(g.id != sectionId):
      continue

    jsonObject["sType"] = %* g.channelGroupType
    jsonObject["sName"] = %* g.name
    jsonObject["sImage"] = %* g.images.thumbnail
    jsonObject["sColor"] = %* g.color

    for c in g.chats:
      if(c.id != chatId):
        continue

      var chatName = c.name
      var chatImage = c.icon
      if(c.chatType == ChatType.OneToOne):
        (chatName, chatImage) = self.controller.getOneToOneChatNameAndImage(c.id)

      jsonObject["cName"] = %* chatName
      jsonObject["cImage"] = %* chatImage
      jsonObject["cColor"] = %* c.color
      jsonObject["cEmoji"] = %* c.emoji
      return $jsonObject

method getChatDetailsAsJson*(self: Module, chatId: string): string =
  let chatDto = self.controller.getChatDetails(chatId)
  var jsonObject = newJObject()
  jsonObject["name"] = %* chatDto.name
  jsonObject["icon"] = %* chatDto.icon
  jsonObject["color"] = %* chatDto.color
  jsonObject["emoji"] = %* chatDto.emoji
  return $jsonObject

method setActiveNotificationGroup*(self: Module, group: int) =
  self.controller.setActiveNotificationGroup(ActivityCenterGroup(group))

method getActiveNotificationGroup*(self: Module): int =
  return self.controller.getActiveNotificationGroup().int

method setActivityCenterReadType*(self: Module, readType: int) =
  self.controller.setActivityCenterReadType(ActivityCenterReadType(readType))

method getActivityCenterReadType*(self: Module): int =
  return self.controller.getActivityCenterReadType().int

method setActivityGroupCounters*(self: Module, counters: Table[ActivityCenterGroup, int]) =
  self.view.setActivityGroupCounters(counters)
