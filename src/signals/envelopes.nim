import json
import types

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:EnvelopeSentSignal = EnvelopeSentSignal()
  if jsonSignal["event"].kind != JNull and jsonSignal["event"].hasKey("ids") and jsonSignal["event"]["ids"].kind != JNull:
    for messageId in jsonSignal["event"]["ids"]:
      signal.messageIds.add(messageId.getStr)
  result = signal
  