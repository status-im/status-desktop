import chronicles
import ../eventemitter

logScope:
  topics = "network-model"

type
  NetworkModel* = ref object
    peers*: seq[string]
    events*: EventEmitter

proc newNetworkModel*(events: EventEmitter): NetworkModel =
  result = NetworkModel()
  result.events = events
  result.peers = @[]

proc peerSummaryChange*(self: NetworkModel, peers: seq[string]) =
  if peers.len == 0:
    self.events.emit("chat:disconnected", Args())
  
  if peers.len > 0:
    self.events.emit("chat:connected", Args())

  self.peers = peers

proc peerCount*(self: NetworkModel): int = self.peers.len
