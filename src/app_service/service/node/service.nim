import nimqml, chronicles, strutils, json

import ../settings/service as settings_service
import ../node_configuration/service as node_configuration_service

import ../../../app/core/eventemitter
import ../../../app/core/fleets/fleet_configuration
import ../../../backend/node as status_node

logScope:
  topics = "node-service"

# Signals which may be emitted by this service:
const SIGNAL_NETWORK_DISCONNECTED* = "networkDisconnected"
const SIGNAL_NETWORK_CONNECTED* = "networkConnected"

QtObject:
    type Service* = ref object of QObject
        events*: EventEmitter
        settingsService: settings_service.Service
        nodeConfigurationService: node_configuration_service.Service
        peers*: seq[string]
        connected: bool

    proc delete*(self: Service) =
       self.QObject.delete

    proc newService*(events: EventEmitter, settingsService: settings_service.Service, nodeConfigurationService: node_configuration_service.Service): Service =
        new(result, delete)
        result.QObject.setup
        result.events = events
        result.settingsService = settingsService
        result.nodeConfigurationService = nodeConfigurationService
        result.peers = @[]
        result.connected = false

    proc init*(self: Service) =
        discard

    proc sendRPCMessageRaw*(self: Service, inputJSON: string): string =
        return status_node.sendRPCMessageRaw(inputJSON)

    proc adminPeers*(): seq[string] =
        let response = status_node.adminPeers().result
        for jsonPeer in response:
            result.add(jsonPeer["enode"].getStr)

    proc wakuV2Peers*(): seq[string] =
        let response = status_node.wakuV2Peers().result
        for (id, proto) in response.pairs:
            if proto.len != 0:
               result.add(id)

    proc fetchPeers*(self: Service): seq[string] =
        return wakuV2Peers()


    proc peerSummaryChange*(self: Service, peers: seq[string]) =
        if peers.len == 0 and self.connected:
            self.connected = false
            self.events.emit(SIGNAL_NETWORK_DISCONNECTED, Args())

        if peers.len > 0 and not self.connected:
            self.connected = true
            self.events.emit(SIGNAL_NETWORK_CONNECTED, Args())

        self.peers = peers

    proc peerCount*(self: Service): int = self.peers.len

    proc isConnected*(self: Service): bool = self.connected

    proc getRpcStats*(self: Service): string =
      try:
        return status_node.getRpcStats()
      except Exception as e:
        let errDescription = e.msg
        error "error: ", errDescription

    proc resetRpcStats*(self: Service) =
      try:
        status_node.resetRpcStats()
      except Exception as e:
        let errDescription = e.msg
        error "error: ", errDescription
