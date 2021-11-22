import json
import base
import signal_type

type PeerStatsSignal* = ref object of Signal
  peers*: seq[string]

proc fromEvent*(T: type PeerStatsSignal, jsonSignal: JsonNode): PeerStatsSignal = 
  result = PeerStatsSignal()
  result.signalType = SignalType.PeerStats
  if jsonSignal["event"].kind != JNull:
    for (node, protocols)  in jsonSignal["event"]["peers"].pairs():
      if protocols.getElems.len != 0:
        result.peers.add(node)
