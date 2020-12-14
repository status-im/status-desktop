import chronicles
import ../eventemitter

logScope:
  topics = "network-model"

type
  NetworkModel* = ref object
    peers*: seq[string]
    events*: EventEmitter
    connected*: bool

proc newNetworkModel*(events: EventEmitter): NetworkModel =
  result = NetworkModel()
  result.events = events
  result.peers = @[]
  result.connected = false

proc peerSummaryChange*(self: NetworkModel, peers: seq[string]) =
  if peers.len == 0 and self.connected:
    self.connected = false
    self.events.emit("network:disconnected", Args())
  
  if peers.len > 0 and not self.connected:
      self.connected = true
      self.events.emit("network:connected", Args())

  self.peers = peers

proc peerCount*(self: NetworkModel): int = self.peers.len

proc isConnected*(self: NetworkModel): bool = self.connected
