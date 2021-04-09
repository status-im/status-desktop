import NimQml, tables, json, chronicles, strutils, json_serialization
import ../libstatus/types as status_types
import types, messages, discovery, whisperFilter, envelopes, expired, wallet, mailserver, communities
import ../status
import ../../eventemitter

logScope:
  topics = "signals"

QtObject:
  type SignalsController* = ref object of QObject
    variant*: QVariant
    status*: Status

  proc newController*(status: Status): SignalsController =
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

    let signalString = jsonSignal["type"].getStr

    trace "Raw signal data", data = $jsonSignal
    
    var signalType: SignalType
    
    try:
      signalType = parseEnum[SignalType](signalString)
    except:
      warn "Unknown signal received", type = signalString
      signalType = SignalType.Unknown
      return

    var signal: Signal = case signalType:
      of SignalType.Message: messages.fromEvent(jsonSignal)
      of SignalType.EnvelopeSent: envelopes.fromEvent(jsonSignal)
      of SignalType.EnvelopeExpired: expired.fromEvent(jsonSignal)
      of SignalType.WhisperFilterAdded: whisperFilter.fromEvent(jsonSignal)
      of SignalType.Wallet: wallet.fromEvent(jsonSignal)
      of SignalType.NodeLogin: Json.decode($jsonSignal, NodeSignal)
      of SignalType.DiscoverySummary: discovery.fromEvent(jsonSignal)
      of SignalType.MailserverRequestCompleted: mailserver.fromCompletedEvent(jsonSignal)
      of SignalType.MailserverRequestExpired: mailserver.fromExpiredEvent(jsonSignal)
      of SignalType.CommunityFound: communities.fromEvent(jsonSignal)
      else: Signal()

    if(signalType == SignalType.NodeLogin):
      if(NodeSignal(signal).event.error != ""):
        error "node.login", error=NodeSignal(signal).event.error

    if(signalType == SignalType.NodeCrashed):
        error "node.crashed", error=statusSignal

    self.status.events.emit(signalType.event, signal)

  proc signalReceived*(self: SignalsController, signal: string) {.signal.}

  proc receiveSignal(self: SignalsController, signal: string) {.slot.} =
    self.processSignal(signal)
    self.signalReceived(signal)
