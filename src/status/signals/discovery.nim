import json
import types

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:DiscoverySummarySignal = DiscoverySummarySignal()
  if jsonSignal["event"].kind != JNull:
    for discoveryItem in jsonSignal["event"]:
      signal.enodes.add(discoveryItem["enode"].getStr)
  result = signal
  