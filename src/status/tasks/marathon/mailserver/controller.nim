import # std libs
  strutils

import # vendor libs
  chronicles, NimQml, json_serialization

import # status-desktop libs
  ../../../status, ../../common as task_runner_common, ./events

logScope:
  topics = "mailserver controller"

################################################################################
##                                                                            ##
## NOTE: MailserverController runs on the main thread                         ##
##                                                                            ##
################################################################################
QtObject:
  type MailserverController* = ref object of QObject
    variant*: QVariant
    status*: Status

  proc newController*(status: Status): MailserverController =
    new(result)
    result.status = status
    result.setup()
    result.variant = newQVariant(result)

  proc setup(self: MailserverController) =
    self.QObject.setup

  proc delete*(self: MailserverController) =
    self.variant.delete
    self.QObject.delete

  proc receiveEvent(self: MailserverController, eventTuple: string) {.slot.} =
    let event = Json.decode(eventTuple, tuple[name: string, arg: MailserverArgs])
    trace "forwarding event from long-running mailserver task to the main thread", event=eventTuple
    self.status.events.emit(event.name, event.arg)