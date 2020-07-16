import NimQml, tables, json, chronicles, strutils, json_serialization
import ../status/libstatus/types as status_types
import types, messages, discovery, whisperFilter, envelopes

logScope:
  topics = "signals"

QtObject:
  type SignalsController* = ref object of QObject
    app: QApplication
    statusSignal: string
    signalSubscribers*: Table[SignalType, seq[SignalSubscriber]]
    variant*: QVariant

  proc newController*(app: QApplication): SignalsController =
    new(result)
    result.app = app
    result.statusSignal = ""
    result.signalSubscribers = initTable[SignalType, seq[SignalSubscriber]]()
    result.setup()
    result.variant = newQVariant(result)

  proc setup(self: SignalsController) =
    self.QObject.setup

  proc init*(self: SignalsController) =
    discard

  proc delete*(self: SignalsController) =
    self.variant.delete
    self.QObject.delete
    self.signalSubscribers = initTable[SignalType, seq[SignalSubscriber]]()

  proc addSubscriber*(self: SignalsController, signalType: SignalType, subscriber: SignalSubscriber) =
    if not self.signalSubscribers.hasKey(signalType):
      self.signalSubscribers[signalType] = @[]
    
    self.signalSubscribers[signalType].add(subscriber)

  proc processSignal(self: SignalsController) =
    var jsonSignal:JsonNode
    try: 
      jsonSignal = self.statusSignal.parseJson
    except:
      error "Invalid signal received", data = self.statusSignal
      return

    let signalString = jsonSignal["type"].getStr

    trace "Raw signal data", data = $jsonSignal
    
    var signalType: SignalType
    
    try:
      signalType = parseEnum[SignalType](signalString)
    except:
      warn "Unknown signal received", type = signalString
      signalType = SignalType.Unknown
      return

    var signal: Signal = Signal(signalType: signalType)
    
    case signalType:
      of SignalType.Message:
        signal = messages.fromEvent(jsonSignal)
      of SignalType.EnvelopeSent:
        signal = envelopes.fromEvent(jsonSignal)
      of SignalType.WhisperFilterAdded:
        signal = whisperFilter.fromEvent(jsonSignal)
      of SignalType.Wallet:
        signal = WalletSignal(content: $jsonSignal)
      of SignalType.NodeLogin:
        signal = Json.decode($jsonSignal, NodeSignal)
      of SignalType.DiscoverySummary:
        signal = discovery.fromEvent(jsonSignal)
      else:
        discard

    signal.signalType = signalType

    if not self.signalSubscribers.hasKey(signalType):
      warn "Unhandled signal received", type = signalString
      self.signalSubscribers[signalType] = @[]

    for subscriber in self.signalSubscribers[signalType]:
      subscriber.onSignal(signal)

  proc statusSignal*(self: SignalsController): string {.slot.} =
    result = self.statusSignal

  proc signalReceived*(self: SignalsController, signal: string) {.signal.}

  proc receiveSignal(self: SignalsController, signal: string) {.slot.} =
    self.statusSignal = signal
    self.processSignal()
    self.signalReceived(signal)

  QtProperty[string] statusSignal:
    read = statusSignal
    write = receiveSignal
    notify = signalReceived
  