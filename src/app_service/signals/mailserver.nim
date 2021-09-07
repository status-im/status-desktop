import json

import base

type MailserverRequestCompletedSignal* = ref object of Signal
  requestID*: string
  lastEnvelopeHash*: string
  cursor*: string
  errorMessage*: string
  error*: bool
  
type MailserverRequestExpiredSignal* = ref object of Signal
  # TODO

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
  