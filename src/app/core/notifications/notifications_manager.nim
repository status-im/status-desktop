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

  proc processNotification(self: NotificationsManager, title: string, message: string, details: NotificationDetails)

  proc setup(self: NotificationsManager, events: EventEmitter) =
    self.QObject.setup
    self.events = events
    self.osNotification = newStatusOSNotification()
    self.soundManager = newStatusSoundManager()

    signalConnect(self.osNotification, "notificationClicked(QString)", self, "onOSNotificationClicked(QString)", 2)
    signalConnect(singletonInstance.globalEvents, "showNormalMessageNotification(QString, QString, QString, QString, QString)", 
      self, "onShowNormalMessageNotification(QString, QString, QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "showMentionMessageNotification(QString, QString, QString, QString, QString)", 
      self, "onShowMentionMessageNotification(QString, QString, QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "showNewContactRequestNotification(QString, QString, QString)", 
      self, "onShowNewContactRequestNotification(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "newCommunityMembershipRequestNotification(QString, QString, QString)", 
      self, "onNewCommunityMembershipRequestNotification(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "myRequestToJoinCommunityHasBeenAcccepted(QString, QString, QString)", 
      self, "onMyRequestToJoinCommunityHasBeenAcccepted(QString, QString, QString)", 2)
    signalConnect(singletonInstance.globalEvents, "myRequestToJoinCommunityHasBeenRejected(QString, QString, QString)", 
      self, "onMyRequestToJoinCommunityHasBeenRejected(QString, QString, QString)", 2)

  proc delete*(self: NotificationsManager) =
    self.osNotification.delete
    self.QObject.delete

  proc newNotificationsManager*(events: EventEmitter): NotificationsManager =
    new(result, delete)
    result.setup(events)

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
    if(details.notificationType == NotificationType.NewMessage or 
      details.notificationType == NotificationType.NewMention):
      let data = ActiveSectionChatArgs(sectionId: details.sectionId, chatId: details.chatId, messageId: details.messageId)
      self.events.emit(SIGNAL_MAKE_SECTION_CHAT_ACTIVE, data)
    else:
      self.events.emit(SIGNAL_OS_NOTIFICATION_CLICKED, ClickedNotificationArgs(details: details))

  proc onShowNormalMessageNotification(self: NotificationsManager, title: string, message: string, sectionId: string, 
    chatId: string, messageId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.NewMessage, sectionId: sectionId, 
    chatId: chatId, messageId: messageId)
    self.processNotification(title, message, details)

  proc onShowMentionMessageNotification(self: NotificationsManager, title: string, message: string, sectionId: string, 
    chatId: string, messageId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.NewMention, sectionId: sectionId, 
    chatId: chatId, messageId: messageId)
    self.processNotification(title, message, details)

  proc onShowNewContactRequestNotification*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.NewContactRequest, sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onNewCommunityMembershipRequestNotification*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.JoinCommunityRequest, sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onMyRequestToJoinCommunityHasBeenAcccepted*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.MyRequestToJoinCommunityAccepted, 
    sectionId: sectionId)
    self.processNotification(title, message, details)

  proc onMyRequestToJoinCommunityHasBeenRejected*(self: NotificationsManager, title: string, message: string, 
    sectionId: string) {.slot.} =
    let details = NotificationDetails(notificationType: NotificationType.MyRequestToJoinCommunityRejected, 
    sectionId: sectionId)
    self.processNotification(title, message, details)

  proc processNotification(self: NotificationsManager, title: string, message: string, details: NotificationDetails) =
    ## This is the main method which need to be called to process an event according to the preferences set in the 
    ## notifications panel of the settings section.
    ## 
    ## This method determines whether a notification need to be displayed or not, what notification to display, whether
    ## to display App or OS notification, what level of anonymous to apply, whether to play sound or not and so...

    # I am not 100% sure about this.
    # According to this:
    # https://github.com/status-im/status-desktop/pull/4789#discussion_r805028513
    # The app should use OS notification only in case it is not the active app or it's minimized at the moment 
    # we're processing an event.
    if(singletonInstance.localAccountSensitiveSettings.getUseOSNotifications() and 
      app_isActive(singletonInstance.engine)):
      return

    var finalTitle = title
    var finalMessage = message

    # Check if notification need to be displayed
    if(singletonInstance.localAccountSensitiveSettings.getNotificationSetting() == NOTIFY_NOTHING_ABOUT and
      (details.notificationType == NotificationType.NewMessage or 
      details.notificationType == NotificationType.NewMention)):
      return

    if(singletonInstance.localAccountSensitiveSettings.getNotificationSetting() == NOTIFY_JUST_ABOUT_MENTIONS and
      details.notificationType == NotificationType.NewMessage):
      return

    if(not singletonInstance.localAccountSensitiveSettings.getNotifyOnNewRequests() and
      details.notificationType == NotificationType.NewContactRequest):
      return

    # Check anonymous level
    if(singletonInstance.localAccountSensitiveSettings.getNotificationMessagePreviewSetting() == PREVIEW_ANONYMOUS):
      finalTitle = "Status"
      finalMessage = "You have a new message"
    elif(singletonInstance.localAccountSensitiveSettings.getNotificationMessagePreviewSetting() == PREVIEW_NAME_ONLY):
      finalMessage = "You have a new message"
        
    # Check whether to display APP or OS notification
    if(singletonInstance.localAccountSensitiveSettings.getUseOSNotifications()):
      let identifier = $(details.toJsonNode())
      debug "Add OS notification", title=finalTitle, message=finalMessage, identifier=identifier
      self.showOSNotification(finalTitle, finalMessage, identifier)  
    else:
      let data = NotificationArgs(title: finalTitle, message: finalMessage, details: details)
      debug "Add APP notification", title=finalTitle, message=finalMessage
      self.events.emit(SIGNAL_DISPLAY_APP_NOTIFICATION, data)
      
    # Check whether to play a sound
    if(singletonInstance.localAccountSensitiveSettings.getNotificationSoundsEnabled()):
      let currentVolume = singletonInstance.localAccountSensitiveSettings.getVolume() * 10
      self.soundManager.setPlayerVolume(currentVolume)
      self.soundManager.playSound(NOTIFICATION_SOUND)