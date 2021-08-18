import NimQml, json
import ../../eventemitter
import os_notification_details

type 
  OsNotificationsArgs* = ref object of Args
    details*: OsNotificationDetails

QtObject:
  type OsNotifications* = ref object of QObject
    events: EventEmitter
    notification: StatusOSNotificationObject

  proc setup(self: OsNotifications, events: EventEmitter) = 
    self.QObject.setup
    self.events = events
    self.notification = newStatusOSNotificationObject()
    signalConnect(self.notification, "notificationClicked(QString)", self,
    "onNotificationClicked(QString)", 2)
  
  proc delete*(self: OsNotifications) =
    self.notification.delete
    self.QObject.delete

  proc newOsNotifications*(events: EventEmitter): OsNotifications =
    new(result, delete)
    result.setup(events)

  proc showNotification*(self: OsNotifications, title: string, 
    message: string, details: OsNotificationDetails, useOSNotifications: bool) =
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

  proc onNotificationClicked*(self: OsNotifications, identifier: string) {.slot.} =
    ## This slot is called once user clicks a notificaiton bubble, "identifier"
    ## contains data which uniquely define that notification.
    let details = toOsNotificationDetails(parseJson(identifier))
    self.events.emit("osNotificationClicked", 
    OsNotificationsArgs(details: details))