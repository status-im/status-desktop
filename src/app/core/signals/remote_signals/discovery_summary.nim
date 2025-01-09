import json

import base
import signal_type

type DiscoverySummarySignal* = ref object of Signal
  enodes*: seq[string]

proc fromEvent*(
    T: type DiscoverySummarySignal, jsonSignal: JsonNode
): DiscoverySummarySignal =
  result = DiscoverySummarySignal()
  result.signalType = SignalType.DiscoverySummary
  if jsonSignal["event"].kind != JNull:
    for discoveryItem in jsonSignal["event"]:
      result.enodes.add(discoveryItem["enode"].getStr)
