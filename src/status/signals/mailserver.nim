import json
import types

proc fromCompletedEvent*(jsonSignal: JsonNode): Signal = 
  var signal:MailserverRequestCompletedSignal = MailserverRequestCompletedSignal()
  if jsonSignal["event"].kind != JNull:
    signal.requestID = jsonSignal["event"]{"requestID"}.getStr()
    signal.lastEnvelopeHash = jsonSignal["event"]{"lastEnvelopeHash"}.getStr()
    signal.cursor = jsonSignal["event"]{"cursor"}.getStr()
    signal.errorMessage = jsonSignal["event"]{"errorMessage"}.getStr()
    signal.error = signal.errorMessage != ""
  result = signal
  
proc fromExpiredEvent*(jsonSignal: JsonNode): Signal = 
  var signal:MailserverRequestExpiredSignal = MailserverRequestExpiredSignal()
  # TODO: parse signal
  result = signal
  