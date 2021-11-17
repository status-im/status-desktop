import NimQml, json, chronicles
import details
import eventemitter

logScope:
  topics = "os-notification-service"

# Signals which may be emitted by this service:
const SIGNAL_OS_NOTIFICATION_CLICKED* = "new-osNotificationClicked" #Once we are done with refactoring we should remove "new-" from all signals

type 
  OsNotificationsArgs* = ref object of Args
    details*: OsNotificationDetails
    
QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    notification: StatusOSNotification

  proc setup(self: Service, events: EventEmitter) = 
    self.QObject.setup
    self.events = events
    self.notification = newStatusOSNotification()
    signalConnect(self.notification, "notificationClicked(QString)", self, "onNotificationClicked(QString)", 2)
  
  proc delete*(self: Service) =
    self.notification.delete
    self.QObject.delete

  proc newService*(events: EventEmitter): Service =
    new(result, delete)
    result.setup(events)

  proc showNotification*(self: Service, title: string, message: string, details: OsNotificationDetails, 
    useOSNotifications: bool) =
    ## This method will add new notification to the Notification center. Param
    ## "details" is used to uniquely define a notification bubble.
     
    # Whether we need to use OS notifications or not should be checked only here, 
    # but because we don't have settings class on the nim side yet, we're using
    # useOSNotifications param sent from the qml side. Once we are able to check 
    # that here, we will remove useOSNotifications param from this method.
    if(not useOSNotifications):
      return

    let identifier = $(details.toJsonNode())
    self.notification.showNotification(title, message, identifier)

  proc onNotificationClicked*(self: Service, identifier: string) {.slot.} =
    ## This slot is called once user clicks a notificaiton bubble, "identifier"
    ## contains data which uniquely define that notification.
    let details = toOsNotificationDetails(parseJson(identifier))
    self.events.emit(SIGNAL_OS_NOTIFICATION_CLICKED, OsNotificationsArgs(details: details))