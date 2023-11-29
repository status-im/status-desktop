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

  # This method might be called with `ChroniclesLogs` event from `nim_status_client`. 
  # In such case we must not log anything to prevent recursive calls.
  # I tried to make a better solution, but ended up with such workaround, check out PR for more details.
  proc processSignal(self: SignalsManager, statusSignal: string, allowLogging: bool) =
    var jsonSignal: JsonNode
    try:
      jsonSignal = statusSignal.parseJson
    except CatchableError:
      if allowLogging:
        error "Invalid signal received", data = statusSignal
      return

    if allowLogging:
      trace "Raw signal data", data = $jsonSignal

    var signal:Signal
    try:
      signal = self.decode(jsonSignal)
    except CatchableError:
      if allowLogging:
        warn "Error decoding signal", err=getCurrentExceptionMsg()
      return

    if signal.signalType == SignalType.NodeLogin and NodeSignal(signal).error != "":
      if allowLogging:
        error "node.login", error=NodeSignal(signal).error

    if signal.signalType == SignalType.NodeCrashed:
      if allowLogging:
        error "node.crashed", error=statusSignal

    self.events.emit(signal.signalType.event, signal)

  proc receiveSignal(self: SignalsManager, signal: string) {.slot.} =
    self.processSignal(signal, allowLogging=true)

  proc receiveChroniclesLogEvent(self: SignalsManager, signal: string) {.slot.} =
    self.processSignal(signal, allowLogging=false)

  proc decode(self: SignalsManager, jsonSignal: JsonNode): Signal =
    let signalString = jsonSignal{"type"}.getStr
    var signalType: SignalType
    try:
      signalType = parseEnum[SignalType](signalString)
    except CatchableError:
      raise newException(ValueError, "Unknown signal received: " & signalString)

    result = case signalType:
      of SignalType.Message: MessageSignal.fromEvent(jsonSignal)
      of SignalType.MessageDelivered: MessageDeliveredSignal.fromEvent(jsonSignal)
      of SignalType.EnvelopeSent: EnvelopeSentSignal.fromEvent(jsonSignal)
      of SignalType.EnvelopeExpired: EnvelopeExpiredSignal.fromEvent(jsonSignal)
      of SignalType.WhisperFilterAdded: WhisperFilterSignal.fromEvent(jsonSignal)
      of SignalType.Wallet: WalletSignal.fromEvent(jsonSignal)
      of SignalType.NodeReady,
        SignalType.NodeCrashed,
        SignalType.NodeStarted,
        SignalType.NodeStopped,
        SignalType.NodeLogin:
          NodeSignal.fromEvent(jsonSignal)
      of SignalType.PeerStats: PeerStatsSignal.fromEvent(jsonSignal)
      of SignalType.DiscoverySummary: DiscoverySummarySignal.fromEvent(jsonSignal)
      of SignalType.MailserverRequestCompleted: MailserverRequestCompletedSignal.fromEvent(jsonSignal)
      of SignalType.MailserverRequestExpired: MailserverRequestExpiredSignal.fromEvent(jsonSignal)
      of SignalType.CommunityFound: CommunitySignal.fromEvent(jsonSignal)
      of SignalType.CuratedCommunitiesUpdated: CuratedCommunitiesSignal.fromEvent(jsonSignal)
      of SignalType.Stats: StatsSignal.fromEvent(jsonSignal)
      of SignalType.ChroniclesLogs: ChroniclesLogsSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestCompleted: HistoryRequestCompletedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestSuccess: HistoryRequestSuccessSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestStarted: HistoryRequestStartedSignal.fromEvent(jsonSignal)
      of SignalType.HistoryRequestFailed: HistoryRequestFailedSignal.fromEvent(jsonSignal)
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
      of SignalType.DownloadingHistoryArchivesStarted: HistoryArchivesSignal.downloadingHistoryArchivesStartedFromEvent(jsonSignal)
      of SignalType.DownloadingHistoryArchivesFinished: HistoryArchivesSignal.downloadingHistoryArchivesFinishedFromEvent(jsonSignal)
      of SignalType.ImportingHistoryArchiveMessages: HistoryArchivesSignal.importingHistoryArchiveMessagesFromEvent(jsonSignal)
      of SignalType.UpdateAvailable: UpdateAvailableSignal.fromEvent(jsonSignal)
      of SignalType.DiscordCategoriesAndChannelsExtracted: DiscordCategoriesAndChannelsExtractedSignal.fromEvent(jsonSignal)
      of SignalType.StatusUpdatesTimedout: StatusUpdatesTimedoutSignal.fromEvent(jsonSignal)
      of SignalType.DiscordCommunityImportFinished: DiscordCommunityImportFinishedSignal.fromEvent(jsonSignal)
      of SignalType.DiscordCommunityImportProgress: DiscordCommunityImportProgressSignal.fromEvent(jsonSignal)
      of SignalType.DiscordCommunityImportCancelled: DiscordCommunityImportCancelledSignal.fromEvent(jsonSignal)
      of SignalType.DiscordChannelImportFinished: DiscordChannelImportFinishedSignal.fromEvent(jsonSignal)
      of SignalType.DiscordChannelImportProgress: DiscordChannelImportProgressSignal.fromEvent(jsonSignal)
      of SignalType.DiscordChannelImportCancelled: DiscordChannelImportCancelledSignal.fromEvent(jsonSignal)
      # sync from waku part
      of SignalType.WakuFetchingBackupProgress: WakuFetchingBackupProgressSignal.fromEvent(jsonSignal)
      of SignalType.WakuBackedUpProfile: WakuBackedUpProfileSignal.fromEvent(jsonSignal)
      of SignalType.WakuBackedUpSettings: WakuBackedUpSettingsSignal.fromEvent(jsonSignal)
      of SignalType.WakuBackedUpKeypair: WakuBackedUpKeypairSignal.fromEvent(jsonSignal)
      of SignalType.WakuBackedUpWatchOnlyAccount: WakuBackedUpWatchOnlyAccountSignal.fromEvent(jsonSignal)
      # pairing
      of SignalType.LocalPairing: LocalPairingSignal.fromEvent(jsonSignal)
      else: Signal()

    result.signalType = signalType
