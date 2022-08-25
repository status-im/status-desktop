import json

import base
import signal_type

import ../../../../app_service/service/contacts/dto/status_update


type StatusUpdatesTimedoutSignal* = ref object of Signal
  statusUpdates*: seq[StatusUpdateDto]

proc fromEvent*(T: type StatusUpdatesTimedoutSignal, jsonSignal: JsonNode): StatusUpdatesTimedoutSignal =
  result = StatusUpdatesTimedoutSignal()
  result.signalType = SignalType.StatusUpdatesTimedout
  for jsonStatusUpdate in jsonSignal["event"]:
    var statusUpdate = jsonStatusUpdate.toStatusUpdateDto()
    result.statusUpdates.add(statusUpdate)
