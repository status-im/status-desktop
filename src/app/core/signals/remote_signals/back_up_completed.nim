import json
import base

type BackUpCompletedSignal* = ref object of Signal
  fileName*: string

proc fromEvent*(T: type BackUpCompletedSignal, event: JsonNode): BackUpCompletedSignal =
  result = BackUpCompletedSignal()
  result.signalType = SignalType.BackUpCompleted

  let e = event["event"]
  if e.contains("fileName"):
    result.fileName = e["fileName"].getStr
