import json

import base

type Filter* = object
  chatId*: string
  symKeyId*: string
  listen*: bool
  filterId*: string
  identity*: string
  topic*: string

type WhisperFilterSignal* = ref object of Signal
  filters*: seq[Filter]

proc toFilter(jsonMsg: JsonNode): Filter =
  result = Filter(
    chatId: jsonMsg{"chatId"}.getStr,
    symKeyId: jsonMsg{"symKeyId"}.getStr,
    listen: jsonMsg{"listen"}.getBool,
    filterId: jsonMsg{"filterId"}.getStr,
    identity: jsonMsg{"identity"}.getStr,
    topic: jsonMsg{"topic"}.getStr,
  )

proc fromEvent*(T: type WhisperFilterSignal, event: JsonNode): WhisperFilterSignal =
  result = WhisperFilterSignal()
  result.signalType = SignalType.WhisperFilterAdded
  if event["event"]{"filters"} != nil:
    for jsonMsg in event["event"]["filters"]:
      result.filters.add(jsonMsg.toFilter)
