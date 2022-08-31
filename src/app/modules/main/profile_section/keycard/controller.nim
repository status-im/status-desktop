import chronicles

import io_interface

import ../../../../core/eventemitter

import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "profile-section-keycard-module-controller"

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
  self.events.on(SignalSharedKeycarModuleFlowTerminated) do(e: Args):
    let args = SharedKeycarModuleFlowTerminatedArgs(e)
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow)

  self.events.on(SignalSharedKeycarModuleDisplayPopup) do(e: Args):
    self.delegate.onDisplayKeycardSharedModuleFlow()