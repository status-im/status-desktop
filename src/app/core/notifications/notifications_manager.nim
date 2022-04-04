import NimQml, json, chronicles

import ../../global/app_signals
import ../../global/global_singleton
import ../eventemitter
import details

export details

logScope:
  topics = "notifications-manager"

const NOTIFICATION_SOUND = "qrc:/imports/assets/audio/notification.wav"

# Signals which may be emitted by this class:
const SIGNAL_ADD_NOTIFICATION_TO_ACTIVITY_CENTER* = "addNotificationToActivityCenter"
const SIGNAL_DISPLAY_APP_NOTIFICATION* = "displayAppNotification"
const SIGNAL_OS_NOTIFICATION_CLICKED* = "osNotificationClicked"

# Notification preferences
const NOTIFY_ABOUT_ALL_MESSAGES = 0
const NOTIFY_JUST_ABOUT_MENTIONS = 1
const NOTIFY_NOTHING_ABOUT = 2

# Anonymous preferences
const PREVIEW_ANONYMOUS = 0
const PREVIEW_NAME_ONLY = 1
const PREVIEW_NAME_AND_MESSAGE = 2

type
  NotificationArgs* = ref object of Args
    title*: string
    message*: string
    details*: NotificationDetails

  ClickedNotificationArgs* = ref object of Args
    details*: NotificationDetails

QtObject:
  type NotificationsManager* = ref object of QObject
    events: EventEmitter
    osNotification: StatusOSNotification
    soundManager: StatusSoundManager
    notificationSetUp: bool

  proc processNotification(self: NotificationsManager, title: string, message: string, details: NotificationDetails)

  proc setup(self: NotificationsManager, events: EventEmitter) =
    self.QObject.setup
    self.events = events

  proc delete*(self: NotificationsManager) =
    if self.notificationSetUp:
      self.osNotification.delete
      self.soundManager.delete
    self.QObject.delete

  proc newNotificationsManager*(events: EventEmitter): NotificationsManager =
    new(result, delete)
    result.setup(events)

  proc init*(self: NotificationsManager) =
    self.osNotification = newStatusOSNotification()
    self.soundManager = newStatusSoundManager()

    signalConnect(self.osNotification, "notificationClicked(QString)", self, "onOSNotificationClicked(QString)", 2)
    signalConnect(singletonInstance.globalEvents, "showTestNotification(QString, QString)", 
      self, "onShowTestNotification(QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "showMessageNotification(QString, QString, QString, bool, bool, QString, bool, QString, int, bool, bool)", 
      self, "onShowMessageNotification(QString, QString, QString, bool, bool, QString, bool, QString, int, bool, bool)", 2)
    signalConnect(singletonInstance.globalEvents, "showNewContactRequestNotification(QString, QString, QString)", 
      self, "onShowNewContactRequestNotification(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "newCommunityMembershipRequestNotification(QString, QString, QString)", 
      self, "onNewCommunityMembershipRequestNotification(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "myRequestToJoinCommunityAcccepted(QString, QString, QString)", 
      self, "onMyRequestToJoinCommunityAcccepted(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "myRequestToJoinCommunityHasBeenRejected(QString, QString, QString)", 
      self, "onMyRequestToJoinCommunityRejected(QString, QString, QString)", 2)
    self.notificationSetUp = true

  proc showOSNotification(self: NotificationsManager, title: string, message: string, identifier: string) =
    ## This method will add new notification to the OS Notification center. Param
    ## "identifier" is used to uniquely define notification bubble.    
    self.osNotification.showNotification(title, message, identifier)

  proc onOSNotificationClicked(self: NotificationsManager, identifier: string) {.slot.} =
    ## This slot is called once user clicks OS notificaiton bubble, "identifier"
    ## contains data which uniquely define that notification.
    debug "OS notification clicked", identifier=identifier
    
    # Make the app the top most window.
    app_makeItActive(singletonInstance.engine)

    let details = toNotificationDetails(parseJson(identifier))
    if(details.notificationType == NotificationType.TestNotification):
      info "Test notification was clicked"
      return

    if(details.notificationType == NotificationType.NewMessage or 
      details.notificationType == NotificationType.NewMessageWithPersonalMention or
      details.notificationType == NotificationType.NewMessageWithGlobalMention):
      let data = ActiveSectionChatArgs(sectionId: details.sectionId, chatId: details.chatId, messageId: details.messageId)
      self.events.emit(SIGNAL_MAKE_SECTION_CHAT_ACTIVE, data)
    else:
      self.events.emit(SIGNAL_OS_NOTIFICATION_CLICKED, ClickedNotificationArgs(details: details))

  proc onShowTestNotification(self: NotificationsManager, title: string, message: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.TestNotification)
    self.processNotification(title, message, details)

  proc onShowMessageNotification(self: NotificationsManager, title: string, message: string, sectionId: string, 
    isCommunitySection: bool, isSectionActive: bool, chatId: string, isChatActive: bool, messageId: string, 
    notificationType: int, isOneToOne: bool, isGroupChat: bool) {.slot.} =
    let details = NotificationDetails(
      notificationType: notificationType.NotificationType,
      sectionId: sectionId, 
      isCommunitySection: isCommunitySection,
      sectionActive: isSectionActive,
      chatId: chatId, 
      chatActive: isChatActive,
      isOneToOne: isOneToOne,
      isGroupChat: isGroupChat,
      messageId: messageId)
    self.processNotification(title, message, details)

  proc onShowNewContactRequestNotification*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.NewContactRequest, sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onNewCommunityMembershipRequestNotification*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.JoinCommunityRequest, sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onMyRequestToJoinCommunityAcccepted*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.MyRequestToJoinCommunityAccepted, 
    sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onMyRequestToJoinCommunityRejected*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.MyRequestToJoinCommunityRejected, 
    sectionId: sectionId)
    self.processNotification(title, message, details)

  proc getExemptions(self: NotificationsManager, id: string): JsonNode =
    # This proc returns exemptions as json object for the passed `id` if there are no set exemptions,
    # json object with the default values will be returned.
    let allExemptions = singletonInstance.localAccountSensitiveSettings.getNotifSettingExemptionsAsJson()
    result = %* {
      EXEMPTION_KEY_MUTE_ALL_MESSAGES: false,
      EXEMPTION_KEY_PERSONAL_MENTIONS: LSS_VALUE_NOTIF_SEND_ALERTS, 
      EXEMPTION_KEY_GLOBAL_MENTIONS: LSS_VALUE_NOTIF_SEND_ALERTS,
      EXEMPTION_KEY_OTHER_MESSAGES: LSS_VALUE_NOTIF_SEND_TURN_OFF
    }
    if(allExemptions.contains(id)):
      let obj = allExemptions[id]
      if(obj.contains(EXEMPTION_KEY_MUTE_ALL_MESSAGES)):
        result[EXEMPTION_KEY_MUTE_ALL_MESSAGES] = obj[EXEMPTION_KEY_MUTE_ALL_MESSAGES]
      if(obj.contains(EXEMPTION_KEY_PERSONAL_MENTIONS)):
        result[EXEMPTION_KEY_PERSONAL_MENTIONS] = obj[EXEMPTION_KEY_PERSONAL_MENTIONS]
      if(obj.contains(EXEMPTION_KEY_GLOBAL_MENTIONS)):
        result[EXEMPTION_KEY_GLOBAL_MENTIONS] = obj[EXEMPTION_KEY_GLOBAL_MENTIONS]
      if(obj.contains(EXEMPTION_KEY_OTHER_MESSAGES)):
        result[EXEMPTION_KEY_OTHER_MESSAGES] = obj[EXEMPTION_KEY_OTHER_MESSAGES]

  proc notificationCheck(self: NotificationsManager, title: string, message: string, details: NotificationDetails,
    notificationWay: string) =
    var data = NotificationArgs(title: title, message: message, details: details)
    # All but the NewMessage notifications go to Activity Center
    if(details.notificationType != NotificationType.NewMessage):
      debug "Add AC notification", title=title, message=message
      self.events.emit(SIGNAL_ADD_NOTIFICATION_TO_ACTIVITY_CENTER, data)

    # An exemption from the diagrams, at least for now, is that we don't need to implement the "Badge Check" block here, 
    # cause that's already handled in appropriate modules.

    if(details.notificationType == NotificationType.NewMessage or 
      details.notificationType == NotificationType.NewMessageWithPersonalMention or
      details.notificationType == NotificationType.NewMessageWithGlobalMention or
      details.notificationType == NotificationType.NewContactRequest or 
      details.notificationType == NotificationType.IdentityVerificationRequest):

      if(notificationWay == LSS_VALUE_NOTIF_SEND_DELIVER_QUIETLY):
        return

      if((details.notificationType == NotificationType.NewMessage or 
        details.notificationType == NotificationType.NewMessageWithPersonalMention or
        details.notificationType == NotificationType.NewMessageWithGlobalMention) and
        details.sectionActive and 
        details.chatActive):
        return

    let appIsActive = app_isActive(singletonInstance.engine)
    if(appIsActive):
      debug "Add APP notification", title=title, message=message
      self.events.emit(SIGNAL_DISPLAY_APP_NOTIFICATION, data)
    
    if(not appIsActive or details.notificationType == NotificationType.TestNotification):
      # Check anonymity level
      if(singletonInstance.localAccountSensitiveSettings.getNotificationMessagePreviewSetting() == PREVIEW_ANONYMOUS):
        data.title = "Status"
        data.message = "You have a new message"
      elif(singletonInstance.localAccountSensitiveSettings.getNotificationMessagePreviewSetting() == PREVIEW_NAME_ONLY):
        data.message = "You have a new message"
      let identifier = $(details.toJsonNode())
      debug "Add OS notification", title=data.title, message=data.message, identifier=identifier
      self.showOSNotification(data.title, data.message, identifier)  
      
    if(singletonInstance.localAccountSensitiveSettings.getNotificationSoundsEnabled()):
      self.soundManager.setPlayerVolume(singletonInstance.localAccountSensitiveSettings.getVolume())
      self.soundManager.playSound(NOTIFICATION_SOUND)

  proc processNotification(self: NotificationsManager, title: string, message: string, details: NotificationDetails) =
    ## This is the main method which need to be called to process an event according to the preferences set in the 
    ## "Notifications & Sounds" panel of the "Settings" section.
    ## 
    ## This method determines whether a notification need to be displayed or not, what notification to display, whether
    ## to display App or OS notification and/or add notification to Activity Center, what level of anonymous to apply, 
    ## whether to play sound or not and so...

    # The flow used here follows these diagrams:
    # - https://drive.google.com/file/d/1L_9c2CMObcDcSuhVUu97s9-_26gtutES/view
    # - https://drive.google.com/file/d/1KmG7lJDJIx6R_HJWeFvMYT2wk32RoTJQ/view

    if(not singletonInstance.localAccountSensitiveSettings.getNotifSettingAllowNotifications()):
      return

    # In case of contact request
    if(details.notificationType == NotificationType.NewContactRequest):
      if(singletonInstance.localAccountSensitiveSettings.getNotifSettingContactRequests() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
        self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingContactRequests())
        return     

    # In case of identity verification request
    elif(details.notificationType == NotificationType.IdentityVerificationRequest):
      if(singletonInstance.localAccountSensitiveSettings.getNotifSettingIdentityVerificationRequests() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
        self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingIdentityVerificationRequests())
        return

    # In case of new message (regardless it's message with mention or not)    
    elif(details.notificationType == NotificationType.NewMessage or 
      details.notificationType == NotificationType.NewMessageWithPersonalMention or
      details.notificationType == NotificationType.NewMessageWithGlobalMention):
      if(singletonInstance.localAccountSensitiveSettings.getNotifSettingAllMessages() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
        self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingAllMessages())
        return

      let messageBelongsToCommunity = details.isCommunitySection
      if(messageBelongsToCommunity):
        let exemptionObj = self.getExemptions(details.sectionId)
        if(exemptionObj[EXEMPTION_KEY_MUTE_ALL_MESSAGES].getBool):
          return

        if(details.notificationType == NotificationType.NewMessageWithPersonalMention and 
          exemptionObj[EXEMPTION_KEY_PERSONAL_MENTIONS].getStr != LSS_VALUE_NOTIF_SEND_TURN_OFF):
          self.notificationCheck(title, message, details, exemptionObj[EXEMPTION_KEY_PERSONAL_MENTIONS].getStr)
          return

        if(details.notificationType == NotificationType.NewMessageWithGlobalMention and 
          exemptionObj[EXEMPTION_KEY_GLOBAL_MENTIONS].getStr != LSS_VALUE_NOTIF_SEND_TURN_OFF):
          self.notificationCheck(title, message, details, exemptionObj[EXEMPTION_KEY_GLOBAL_MENTIONS].getStr)
          return

        if(details.notificationType == NotificationType.NewMessage and 
          exemptionObj[EXEMPTION_KEY_OTHER_MESSAGES].getStr != LSS_VALUE_NOTIF_SEND_TURN_OFF):
          self.notificationCheck(title, message, details, exemptionObj[EXEMPTION_KEY_OTHER_MESSAGES].getStr)
          return

        return
      else:
        if(details.isOneToOne or details.isGroupChat):
          let exemptionObj = self.getExemptions(details.chatId)
          if(exemptionObj[EXEMPTION_KEY_MUTE_ALL_MESSAGES].getBool):
            return

        if(details.notificationType == NotificationType.NewMessageWithPersonalMention and 
          singletonInstance.localAccountSensitiveSettings.getNotifSettingPersonalMentions() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
          self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingPersonalMentions())
          return

        if(details.notificationType == NotificationType.NewMessageWithGlobalMention and 
          singletonInstance.localAccountSensitiveSettings.getNotifSettingGlobalMentions() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
          self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingGlobalMentions())
          return
          
        if(details.notificationType == NotificationType.NewMessage):
          if(details.isOneToOne and
            singletonInstance.localAccountSensitiveSettings.getNotifSettingOneToOneChats() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
            self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingOneToOneChats())
            return

          if(details.isGroupChat and
            singletonInstance.localAccountSensitiveSettings.getNotifSettingGroupChats() != LSS_VALUE_NOTIF_SEND_TURN_OFF):
            self.notificationCheck(title, message, details, singletonInstance.localAccountSensitiveSettings.getNotifSettingGroupChats())
            return

    # In all other cases (TestNotification, AcceptedContactRequest, JoinCommunityRequest,  MyRequestToJoinCommunityAccepted,
    # MyRequestToJoinCommunityRejected)
    else:
      self.notificationCheck(title, message, details, "")