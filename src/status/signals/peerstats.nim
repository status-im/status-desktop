import json
import types

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:PeerStatsSignal = PeerStatsSignal()
  if jsonSignal["event"].kind != JNull:
    for (node, protocols)  in jsonSignal["event"]["peers"].pairs():
      if protocols.getElems.len != 0:
        signal.peers.add(node)
  result = signal
  