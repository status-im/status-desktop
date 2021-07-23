import json
import types

proc toStats(jsonMsg: JsonNode): Stats =
  result = Stats(
    uploadRate: uint64(jsonMsg{"uploadRate"}.getBiggestInt()),
    downloadRate: uint64(jsonMsg{"downloadRate"}.getBiggestInt())
  )

proc fromEvent*(event: JsonNode): Signal = 
  var signal:StatsSignal = StatsSignal()
  signal.stats = event["event"].toStats
  result = signal