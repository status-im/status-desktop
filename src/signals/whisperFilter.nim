import json
import types

proc toFilter(jsonMsg: JsonNode): Filter =
  result = Filter(
    chatId: jsonMsg{"chatId"}.getStr,
    symKeyId: jsonMsg{"symKeyId"}.getStr,
    listen: jsonMsg{"listen"}.getBool,
    filterId: jsonMsg{"filterId"}.getStr,
    identity: jsonMsg{"identity"}.getStr,
    topic: jsonMsg{"topic"}.getStr,
  )

proc fromEvent*(event: JsonNode): Signal = 
  var signal:WhisperFilterSignal = WhisperFilterSignal()

  if event["event"]{"filters"} != nil:
    for jsonMsg in event["event"]["filters"]:
      signal.filters.add(jsonMsg.toFilter)

  result = signal