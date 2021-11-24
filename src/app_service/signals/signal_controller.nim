import NimQml, json, chronicles, json_serialization
import status/signals
import status/status
import eventemitter

logScope:
  topics = "signals"

QtObject:
  type SignalsController* = ref object of QObject
    variant*: QVariant
    status*: Status

  proc newSignalsController*(status: Status): SignalsController =
    new(result)
    result.status = status
    result.setup()
    result.variant = newQVariant(result)

  proc setup(self: SignalsController) =
    self.QObject.setup

  proc delete*(self: SignalsController) =
    self.variant.delete
    self.QObject.delete

  proc processSignal(self: SignalsController, statusSignal: string) =
    var jsonSignal: JsonNode
    try: 
      jsonSignal = statusSignal.parseJson
    except:
      error "Invalid signal received", data = statusSignal
      return

    echo statusSignal

    trace "Raw signal data", data = $jsonSignal
    
    var signal:Signal
    try:
      signal = decode(jsonSignal)
    except:
      warn "Error decoding signal", err=getCurrentExceptionMsg()
      return

    if(signal.signalType == SignalType.NodeLogin):
      if(NodeSignal(signal).event.error != ""):
        error "node.login", error=NodeSignal(signal).event.error

    if(signal.signalType == SignalType.NodeCrashed):
        error "node.crashed", error=statusSignal

    self.status.events.emit(signal.signalType.event, signal)

  proc signalReceived*(self: SignalsController, signal: string) {.signal.}

  proc receiveSignal(self: SignalsController, signal: string) {.slot.} =
    self.processSignal(signal)
    self.signalReceived(signal)
