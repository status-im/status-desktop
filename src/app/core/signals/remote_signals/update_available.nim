import json
import base
import signal_type

type UpdateAvailableSignal* = ref object of Signal
  available*: bool
  version*: string
  url*: string

proc fromEvent*(T: type UpdateAvailableSignal, jsonSignal: JsonNode): UpdateAvailableSignal =
  result = UpdateAvailableSignal()
  result.signalType = SignalType.UpdateAvailable
  if jsonSignal["event"].kind != JNull:
    result.available = jsonSignal["event"]["available"].getBool()
    result.version = jsonSignal["event"]["version"].getStr()
    result.url = jsonSignal["event"]["url"].getStr()

