import json
import base
import signal_type

type ChroniclesLogsSignal* = ref object of Signal
  content*: string

proc fromEvent*(
    T: type ChroniclesLogsSignal, jsonSignal: JsonNode
): ChroniclesLogsSignal =
  result = ChroniclesLogsSignal()
  result.signalType = SignalType.ChroniclesLogs
  if jsonSignal["event"].kind != JNull:
    result.content = jsonSignal["event"].getStr()
