import chronicles
import io_interface

import app/core/eventemitter

logScope:
  topics = "onboarding-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard
