import json

import base
import signal_type

type Stats* = object
  uploadRate*: uint64
  downloadRate*: uint64

type StatsSignal* = ref object of Signal
  stats*: Stats

proc toStats(jsonMsg: JsonNode): Stats =
  result = Stats(
    uploadRate: uint64(jsonMsg{"uploadRate"}.getBiggestInt()),
    downloadRate: uint64(jsonMsg{"downloadRate"}.getBiggestInt()),
  )

proc fromEvent*(T: type StatsSignal, event: JsonNode): StatsSignal =
  result = StatsSignal()
  result.signalType = SignalType.Stats
  result.stats = event["event"].toStats
