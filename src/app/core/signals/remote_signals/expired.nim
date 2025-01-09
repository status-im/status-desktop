import json

import base
import signal_type

type EnvelopeExpiredSignal* = ref object of Signal
  messageIds*: seq[string]

proc fromEvent*(
    T: type EnvelopeExpiredSignal, jsonSignal: JsonNode
): EnvelopeExpiredSignal =
  result = EnvelopeExpiredSignal()
  result.signalType = SignalType.EnvelopeExpired
  if jsonSignal["event"].kind != JNull and jsonSignal["event"].hasKey("ids") and
      jsonSignal["event"]["ids"].kind != JNull:
    for messageId in jsonSignal["event"]["ids"]:
      result.messageIds.add(messageId.getStr)
