import NimQml, json, strutils, chronicles, json_serialization
import ../eventemitter

include types

logScope:
  topics = "signals-manager"

QtObject:
  type SignalsManager* = ref object of QObject
    events: EventEmitter

  #################################################
  # Forward declaration section
  proc decode(self: SignalsManager, jsonSignal: JsonNode): Signal
  #################################################

  proc setup(self: SignalsManager) =
    self.QObject.setup

  proc delete*(self: SignalsManager) =
    self.QObject.delete

  proc newSignalsManager*(events: EventEmitter): SignalsManager =
    new(result)
    result.setup()
    result.events = events

  proc processSignal(self: SignalsManager, statusSignal: string) =
    var jsonSignal: JsonNode
    try:
      jsonSignal = statusSignal.parseJson
    except:
      error "Invalid signal received", data = statusSignal
      return

    trace "Raw signal data", data = $jsonSignal

    var signal:Signal
    try:
      signal = self.decode(jsonSignal)
    except:
      warn "Error decoding signal", err=getCurrentExceptionMsg()
      return

    if(signal.signalType == SignalType.NodeLogin):
      if(NodeSignal(signal).event.error != ""):
        error "node.login", error=NodeSignal(signal).event.error

    if(signal.signalType == SignalType.NodeCrashed):
        error "node.crashed", error=statusSignal

    self.events.emit(signal.signalType.event, signal)

  proc receiveSignal(self: SignalsManager, signal: string) {.slot.} =
    self.processSignal(signal)

  proc decode(self: SignalsManager, jsonSignal: JsonNode): Signal =
    let signalString = jsonSignal{"type"}.getStr
    var signalType: SignalType
    try:
      signalType = parseEnum[SignalType](signalString)
    except:
      raise newException(ValueError, "Unknown signal received: " & signalString)

    result = case signalType:
      of SignalType.Message: MessageSignal.fromEvent(jsonSignal)
      of SignalType.EnvelopeSent: EnvelopeSentSignal.fromEvent(jsonSignal)
      of SignalType.EnvelopeExpired: EnvelopeExpiredSignal.fromEvent(jsonSignal)
      of SignalType.WhisperFilterAdded: WhisperFilterSignal.fromEvent(jsonSignal)
      of SignalType.Wallet: WalletSignal.fromEvent(jsonSignal)
      of SignalType.NodeLogin: Json.decode($jsonSignal, NodeSignal)
      of SignalType.PeerStats: PeerStatsSignal.fromEvent(jsonSignal)
      of SignalType.DiscoverySummary: DiscoverySummarySignal.fromEvent(jsonSignal)
      of SignalType.MailserverRequestCompleted: MailserverRequestCompletedSignal.fromEvent(jsonSignal)
      of SignalType.MailserverRequestExpired: MailserverRequestExpiredSignal.fromEvent(jsonSignal)
      of SignalType.CommunityFound: CommunitySignal.fromEvent(jsonSignal)
      of SignalType.Stats: StatsSignal.fromEvent(jsonSignal)
      of SignalType.ChroniclesLogs: ChroniclesLogsSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestCompleted: HistoryRequestCompletedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestStarted: HistoryRequestStartedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestFailed: HistoryRequestFailedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestBatchProcessed: HistoryRequestBatchProcessedSignal.fromEvent(jsonSignal)
      of SignalType.KeycardConnected: KeycardConnectedSignal.fromEvent(jsonSignal)
      of SignalType.MailserverAvailable: MailserverAvailableSignal.fromEvent(jsonSignal)
      of SignalType.MailserverChanged: MailserverChangedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryArchivesProtocolEnabled: HistoryArchivesSignal.historyArchivesProtocolEnabledFromEvent(jsonSignal)
      of SignalType.HistoryArchivesProtocolDisabled: HistoryArchivesSignal.historyArchivesProtocolDisabledFromEvent(jsonSignal)
      of SignalType.CreatingHistoryArchives: HistoryArchivesSignal.creatingHistoryArchivesFromEvent(jsonSignal)
      of SignalType.NoHistoryArchivesCreated: HistoryArchivesSignal.noHistoryArchivesCreatedFromEvent(jsonSignal)
      of SignalType.HistoryArchivesCreated: HistoryArchivesSignal.historyArchivesCreatedFromEvent(jsonSignal)
      of SignalType.HistoryArchivesSeeding: HistoryArchivesSignal.historyArchivesSeedingFromEvent(jsonSignal)
      of SignalType.HistoryArchivesUnseeded: HistoryArchivesSignal.historyArchivesUnseededFromEvent(jsonSignal)
      of SignalType.HistoryArchiveDownloaded: HistoryArchivesSignal.historyArchiveDownloadedFromEvent(jsonSignal)
      of SignalType.UpdateAvailable: UpdateAvailableSignal.fromEvent(jsonSignal)
      else: Signal()

    result.signalType = signalType
