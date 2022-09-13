import chronicles

import io_interface

import ../../../../core/eventemitter

import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "profile-section-keycard-module-controller"

const UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER* = "Settings-KeycardModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  
proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED) do(e: Args):
    let args = SharedKeycarModuleFlowTerminatedArgs(e)
    if args.uniqueIdentifier != UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER:
      return
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP) do(e: Args):
    let args = SharedKeycarModuleBaseArgs(e)
    if args.uniqueIdentifier != UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER:
      return
    self.delegate.onDisplayKeycardSharedModuleFlow()
