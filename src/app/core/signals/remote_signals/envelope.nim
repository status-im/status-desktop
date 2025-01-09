import json

import base
import signal_type

type EnvelopeSentSignal* = ref object of Signal
  messageIds*: seq[string]

proc fromEvent*(T: type EnvelopeSentSignal, jsonSignal: JsonNode): EnvelopeSentSignal =
  result = EnvelopeSentSignal()
  result.signalType = SignalType.EnvelopeSent
  if jsonSignal["event"].kind != JNull and jsonSignal["event"].hasKey("ids") and
      jsonSignal["event"]["ids"].kind != JNull:
    for messageId in jsonSignal["event"]["ids"]:
      result.messageIds.add(messageId.getStr)
