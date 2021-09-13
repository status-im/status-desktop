import NimQml, json, chronicles

import status/[status]
import status/notifications/[os_notifications]
import status/types/[os_notification]

logScope:
  topics = "os-notification-service"

QtObject:
  type OsNotificationService* = ref object of QObject
    status: Status
    notification: StatusOSNotification

  proc setup(self: OsNotificationService, status: Status) = 
    self.QObject.setup
    self.status = status
    self.notification = newStatusOSNotification()
    signalConnect(self.notification, "notificationClicked(QString)", self,
    "onNotificationClicked(QString)", 2)
  
  proc delete*(self: OsNotificationService) =
    self.notification.delete
    self.QObject.delete

  proc newOsNotificationService*(status: Status): OsNotificationService =
    new(result, delete)
    result.setup(status)

  proc showNotification*(self: OsNotificationService, title: string, 
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

  proc onNotificationClicked*(self: OsNotificationService, identifier: string) {.slot.} =
    ## This slot is called once user clicks a notificaiton bubble, "identifier"
    ## contains data which uniquely define that notification.
    self.status.osnotifications.onNotificationClicked(identifier)