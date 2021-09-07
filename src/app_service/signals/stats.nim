import json

import base

type Stats* = object
  uploadRate*: uint64
  downloadRate*: uint64

type StatsSignal* = ref object of Signal
  stats*: Stats

proc toStats(jsonMsg: JsonNode): Stats =
  result = Stats(
    uploadRate: uint64(jsonMsg{"uploadRate"}.getBiggestInt()),
    downloadRate: uint64(jsonMsg{"downloadRate"}.getBiggestInt())
  )

proc fromEvent*(event: JsonNode): Signal = 
  var signal:StatsSignal = StatsSignal()
  signal.stats = event["event"].toStats
  result = signal