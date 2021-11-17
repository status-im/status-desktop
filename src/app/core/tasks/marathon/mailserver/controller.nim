import # std libs
  strutils

import # vendor libs
  chronicles, NimQml, json_serialization

import events
import ../../common as task_runner_common

import eventemitter

logScope:
  topics = "mailserver controller"

################################################################################
##                                                                            ##
## NOTE: MailserverController runs on the main thread                         ##
##                                                                            ##
################################################################################
QtObject:
  type MailserverController* = ref object of QObject
    events: EventEmitter

  proc newMailserverController*(events: EventEmitter): MailserverController =
    new(result)
    result.events = events
    result.setup()

  proc setup(self: MailserverController) =
    self.QObject.setup

  proc delete*(self: MailserverController) =
    self.QObject.delete

  proc receiveEvent(self: MailserverController, eventTuple: string) {.slot.} =
    let event = Json.decode(eventTuple, tuple[name: string, arg: MailserverArgs])
    trace "forwarding event from long-running mailserver task to the main thread", event=eventTuple
    self.events.emit(event.name, event.arg)