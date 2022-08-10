import json, tables
import base

import ../../../../app_service/service/community/dto/[community]
import signal_type

type CommunitySignal* = ref object of Signal
  community*: CommunityDto

type HistoryArchivesSignal* = ref object of Signal
  communityId*: string
  begin*: int
  to*: int

type DiscordCategoriesAndChannelsExtractedSignal* = ref object of Signal
  categories*: seq[DiscordCategoryDto]
  channels*: seq[DiscordChannelDto]
  oldestMessageTimestamp*: int
  errors*: Table[string, DiscordImportError]
  errorsCount*: int

type DiscordCommunityImportProgressSignal* = ref object of Signal
  communityId*: string
  tasks*: Table[string, DiscordImportTaskProgress]
  progress*: float
  errorsCount*: int
  warningsCount*: int
  stopped*: bool

type DiscordCommunityImportFinishedSignal* = ref object of Signal
  communityId*: string

proc fromEvent*(T: type CommunitySignal, event: JsonNode): CommunitySignal =
  result = CommunitySignal()
  result.signalType = SignalType.CommunityFound
  result.community = event["event"].toCommunityDto()

proc fromEvent*(T: type DiscordCategoriesAndChannelsExtractedSignal, event: JsonNode): DiscordCategoriesAndChannelsExtractedSignal =
  result = DiscordCategoriesAndChannelsExtractedSignal()

  result.signalType = SignalType.DiscordCategoriesAndChannelsExtracted
  result.categories = parseDiscordCategories(event["event"])
  result.channels = parseDiscordChannels(event["event"])

  if event["event"]{"oldestMessageTimestamp"}.kind == JInt:
    result.oldestMessageTimestamp = event["event"]{"oldestMessageTimestamp"}.getInt()

  result.errors = initTable[string, DiscordImportError]()
  result.errorsCount = 0

  if event["event"]["errors"].kind == JObject:
    for key in event["event"]["errors"].keys:
      let responseErr = event["event"]["errors"][key]
      var err = DiscordImportError()
      err.code = responseErr["code"].getInt()
      err.message = responseErr["message"].getStr()
      result.errors[key] = err
      result.errorsCount = result.errorsCount+1

proc fromEvent*(T: type DiscordCommunityImportProgressSignal, event: JsonNode): DiscordCommunityImportProgressSignal =
  result = DiscordCommunityImportProgressSignal()
  result.signalType = SignalType.DiscordCommunityImportProgress
  result.tasks = initTable[string, DiscordImportTaskProgress]()

  if event["event"]["importProgress"].kind == JObject:
    let importProgressObj = event["event"]["importProgress"]

    result.communityId = importProgressObj{"communityId"}.getStr()
    result.progress = importProgressObj{"progress"}.getFloat()
    result.errorsCount = importProgressObj{"errorsCount"}.getInt()
    result.warningsCount = importProgressObj{"warningsCount"}.getInt()
    result.stopped = importProgressObj{"stopped"}.getBool()

    if importProgressObj["tasks"].kind == JObject:
      for task in importProgressObj["tasks"].keys:
        result.tasks[task] = importProgressObj["tasks"][task].toDiscordImportTaskProgress()

proc fromEvent*(T: type DiscordCommunityImportFinishedSignal, event: JsonNode): DiscordCommunityImportFinishedSignal =
  result = DiscordCommunityImportFinishedSignal()
  result.signalType = SignalType.DiscordCommunityImportFinished
  result.communityId = event["event"]{"communityId"}.getStr()

proc createFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal()
  result.communityId = event["event"]{"communityId"}.getStr()
  result.begin = event["event"]{"from"}.getInt()
  result.to = event["event"]{"to"}.getInt()

proc historyArchivesProtocolEnabledFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchivesProtocolEnabled

proc historyArchivesProtocolDisabledFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchivesProtocolDisabled

proc creatingHistoryArchivesFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.CreatingHistoryArchives

proc historyArchivesCreatedFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchivesCreated

proc noHistoryArchivesCreatedFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.NoHistoryArchivesCreated

proc historyArchivesSeedingFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchivesSeeding

proc historyArchivesUnseededFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchivesUnseeded

proc historyArchiveDownloadedFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal.createFromEvent(event)
  result.signalType = SignalType.HistoryArchiveDownloaded
