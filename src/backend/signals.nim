import json, json_serialization, strutils
import signals/[base, chronicles_logs, community, discovery_summary, envelope, expired, mailserver, messages, peerstats, signal_type, stats, wallet, whisper_filter, keycard]

export base, chronicles_logs, community, discovery_summary, envelope, expired, mailserver, messages, peerstats, signal_type, stats, wallet, whisper_filter

proc decode*(jsonSignal: JsonNode): Signal =
  let signalString = jsonSignal{"type"}.getStr
  var signalType: SignalType
  try:
    signalType = parseEnum[SignalType](signalString)
  except:
    raise newException(ValueError, "Unknown signal received: " & signalString)

  result = case signalType:
    of SignalType.Message: MessageSignal.fromEvent(jsonSignal, true)
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
    of SignalType.MailserverNotWorking: MailserverNotWorkingSignal.fromEvent(jsonSignal)
    of SignalType.HistoryArchivesProtocolEnabled: historyArchivesProtocolEnabledFromEvent(jsonSignal)
    of SignalType.HistoryArchivesProtocolDisabled: historyArchivesProtocolDisabledFromEvent(jsonSignal)
    of SignalType.CreatingHistoryArchives: creatingHistoryArchivesFromEvent(jsonSignal)
    of SignalType.NoHistoryArchivesCreated: noHistoryArchivesCreatedFromEvent(jsonSignal)
    of SignalType.HistoryArchivesCreated: historyArchivesCreatedFromEvent(jsonSignal)
    of SignalType.HistoryArchivesSeeding: historyArchivesSeedingFromEvent(jsonSignal)
    of SignalType.HistoryArchivesUnseeded: historyArchivesUnseededFromEvent(jsonSignal)
    of SignalType.HistoryArchiveDownloaded: historyArchiveDownloadedFromEvent(jsonSignal)
    else: Signal()

  result.signalType = signalType
