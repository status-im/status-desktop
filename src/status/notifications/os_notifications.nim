import json

import ../types/[os_notification]
import ../../eventemitter

type OsNotifications* = ref object
  events: EventEmitter
  
proc delete*(self: OsNotifications) =
  discard

proc newOsNotifications*(events: EventEmitter): OsNotifications =
  result = OsNotifications()
  result.events = events

proc onNotificationClicked*(self: OsNotifications, identifier: string) =
  ## This slot is called once user clicks a notificaiton bubble, "identifier"
  ## contains data which uniquely define that notification.
  let details = toOsNotificationDetails(parseJson(identifier))
  self.events.emit("osNotificationClicked", OsNotificationsArgs(details: details))