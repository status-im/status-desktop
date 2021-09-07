import json

import base

type EnvelopeExpiredSignal* = ref object of Signal
  messageIds*: seq[string]

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:EnvelopeExpiredSignal = EnvelopeExpiredSignal()
  if jsonSignal["event"].kind != JNull and jsonSignal["event"].hasKey("ids") and jsonSignal["event"]["ids"].kind != JNull:
    for messageId in jsonSignal["event"]["ids"]:
      signal.messageIds.add(messageId.getStr)
  result = signal
  