import json, tables
import base

import ../../../../app_service/service/community/dto/[community]
import ../../../../app_service/service/chat/dto/[chat]
import signal_type

type CommunitySignal* = ref object of Signal
  community*: CommunityDto

type CuratedCommunitiesSignal* = ref object of Signal
  communities*: seq[CommunityDto]
  unknownCommunities*: seq[string]

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
  communityImages*: Images
  communityName*: string
  tasks*: seq[DiscordImportTaskProgress]
  progress*: float
  errorsCount*: int
  warningsCount*: int
  stopped*: bool
  totalChunksCount*: int
  currentChunk*: int

type DiscordChannelImportProgressSignal* = ref object of Signal
  channelId*: string
  channelName*: string
  tasks*: seq[DiscordImportTaskProgress]
  progress*: float
  errorsCount*: int
  warningsCount*: int
  stopped*: bool
  totalChunksCount*: int
  currentChunk*: int

type DiscordCommunityImportCancelledSignal* = ref object of Signal
  communityId*: string

type DiscordCommunityImportFinishedSignal* = ref object of Signal
  communityId*: string

type DiscordChannelImportCancelledSignal* = ref object of Signal
  channelId*: string

type DiscordChannelImportFinishedSignal* = ref object of Signal
  communityId*: string
  channelId*: string

proc fromEvent*(T: type CommunitySignal, event: JsonNode): CommunitySignal =
  result = CommunitySignal()
  result.signalType = SignalType.CommunityFound
  result.community = event["event"].toCommunityDto()

proc fromEvent*(T: type CuratedCommunitiesSignal, event: JsonNode): CuratedCommunitiesSignal =
  result = CuratedCommunitiesSignal()
  result.signalType = SignalType.CuratedCommunitiesUpdated

  result.communities = @[]
  if event["event"]["communities"].kind == JObject:
    for (communityId, community) in event["event"]["communities"].pairs():
      result.communities.add(community.toCommunityDto())

  if event["event"]["unknownCommunities"].kind == JObject:
    for communityId in event["event"]["unknownCommunities"].items():
      result.unknownCommunities.add(communityId.getStr)

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
  result.tasks = @[]

  if event["event"]["importProgress"].kind == JObject:
    let importProgressObj = event["event"]["importProgress"]

    result.communityId = importProgressObj{"communityId"}.getStr()
    result.communityName = importProgressObj{"communityName"}.getStr()
    result.progress = importProgressObj{"progress"}.getFloat()
    result.errorsCount = importProgressObj{"errorsCount"}.getInt()
    result.warningsCount = importProgressObj{"warningsCount"}.getInt()
    result.stopped = importProgressObj{"stopped"}.getBool()
    result.totalChunksCount = importProgressObj{"totalChunksCount"}.getInt()
    result.currentChunk = importProgressObj{"currentChunk"}.getInt()

    if importProgressObj["communityImages"].kind == JObject:
      result.communityImages = chat.toImages(importProgressObj["communityImages"])

    if importProgressObj["tasks"].kind == JArray:
      for task in importProgressObj["tasks"]:
        result.tasks.add(task.toDiscordImportTaskProgress())

proc fromEvent*(T: type DiscordChannelImportProgressSignal, event: JsonNode): DiscordChannelImportProgressSignal =
  result = DiscordChannelImportProgressSignal()
  result.signalType = SignalType.DiscordChannelImportProgress
  result.tasks = @[]

  if event["event"]["importProgress"].kind == JObject:
    let importProgressObj = event["event"]["importProgress"]

    result.channelId = importProgressObj{"channelId"}.getStr()
    result.channelName = importProgressObj{"channelName"}.getStr()
    result.progress = importProgressObj{"progress"}.getFloat()
    result.errorsCount = importProgressObj{"errorsCount"}.getInt()
    result.warningsCount = importProgressObj{"warningsCount"}.getInt()
    result.stopped = importProgressObj{"stopped"}.getBool()
    result.totalChunksCount = importProgressObj{"totalChunksCount"}.getInt()
    result.currentChunk = importProgressObj{"currentChunk"}.getInt()

    if importProgressObj["tasks"].kind == JArray:
      for task in importProgressObj["tasks"]:
        result.tasks.add(task.toDiscordImportTaskProgress())

proc fromEvent*(T: type DiscordCommunityImportFinishedSignal, event: JsonNode): DiscordCommunityImportFinishedSignal =
  result = DiscordCommunityImportFinishedSignal()
  result.signalType = SignalType.DiscordCommunityImportFinished
  result.communityId = event["event"]{"communityId"}.getStr()

proc fromEvent*(T: type DiscordCommunityImportCancelledSignal, event: JsonNode): DiscordCommunityImportCancelledSignal =
  result = DiscordCommunityImportCancelledSignal()
  result.signalType = SignalType.DiscordCommunityImportCancelled
  result.communityId = event["event"]{"communityId"}.getStr()

proc fromEvent*(T: type DiscordChannelImportFinishedSignal, event: JsonNode): DiscordChannelImportFinishedSignal =
  result = DiscordChannelImportFinishedSignal()
  result.signalType = SignalType.DiscordChannelImportFinished
  result.communityId = event["event"]{"communityId"}.getStr()
  result.channelId = event["event"]{"channelId"}.getStr()

proc fromEvent*(T: type DiscordChannelImportCancelledSignal, event: JsonNode): DiscordChannelImportCancelledSignal =
  result = DiscordChannelImportCancelledSignal()
  result.signalType = SignalType.DiscordChannelImportCancelled
  result.channelId = event["event"]{"channelId"}.getStr()

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

proc downloadingHistoryArchivesStartedFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal()
  result.communityId = event["event"]{"communityId"}.getStr()
  result.signalType = SignalType.DownloadingHistoryArchivesStarted

proc importingHistoryArchiveMessagesFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal()
  result.communityId = event["event"]{"communityId"}.getStr()
  result.signalType = SignalType.ImportingHistoryArchiveMessages

proc downloadingHistoryArchivesFinishedFromEvent*(T: type HistoryArchivesSignal, event: JsonNode): HistoryArchivesSignal =
  result = HistoryArchivesSignal()
  result.communityId = event["event"]{"communityId"}.getStr()
  result.signalType = SignalType.DownloadingHistoryArchivesFinished
