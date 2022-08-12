import chronicles, strutils, os
import uuids
import io_interface

import ../../../global/global_singleton
import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service

logScope:
  topics = "keycard-popup-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keycardService: keycard_service.Service
    connectionIds: seq[UUID]
    tmpKeycardContainsMetadata: bool

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.tmpKeycardContainsMetadata = false

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  let handlerId = self.events.onWithUUID(SignalKeycardResponse) do(e: Args):
    let args = KeycardArgs(e)
    self.delegate.onKeycardResponse(args.flowType, args.flowEvent)
  self.connectionIds.add(handlerId)

proc disconnect*(self: Controller) =
  for id in self.connectionIds:
    self.events.disconnect(id)

proc setKeycardData*(self: Controller, value: string) =
  self.delegate.setKeycardData(value)

proc containsMetadata*(self: Controller): bool =
  return self.tmpKeycardContainsMetadata

proc setContainsMetadata*(self: Controller, value: bool) =
  self.tmpKeycardContainsMetadata = value

proc cancelCurrentFlow(self: Controller) =
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one, 
  # this way we're giving to the keycard some time to cancel the current flow 
  sleep(200)

proc runGetAppInfoFlow*(self: Controller, factoryReset = false) =
  self.cancelCurrentFlow()
  self.keycardService.startGetAppInfoFlow(factoryReset)

proc runGetMetadataFlow*(self: Controller) =
  self.cancelCurrentFlow()
  self.keycardService.startGetMetadataFlow()

proc resumeCurrentFlowLater*(self: Controller) =
  self.keycardService.resumeCurrentFlowLater()

proc terminateCurrentFlow*(self: Controller, lastStepInTheCurrentFlow: bool) =
  let data = SharedKeycarModuleFlowTerminatedArgs(lastStepInTheCurrentFlow: lastStepInTheCurrentFlow)
  self.events.emit(SignalSharedKeycarModuleFlowTerminated, data)