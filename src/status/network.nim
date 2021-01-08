import chronicles
import ../eventemitter
import libstatus/settings
import json
import uuids
import json_serialization
import libstatus/types

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

proc addNetwork*(self: NetworkModel, name: string, endpoint: string, networkId: int, networkType: string) =
  var networks = getSetting[JsonNode](Setting.Networks_Networks)
  let id = genUUID()
  networks.elems.add(%*{
    "id": $genUUID(),
    "name": name,
    "config": {
      "NetworkId": networkId,
      "DataDir": "/ethereum/" & networkType,
      "UpstreamConfig": {
        "Enabled": true,
        "URL": endpoint
      }
    }
  })
  discard saveSetting(Setting.Networks_Networks, $networks)
