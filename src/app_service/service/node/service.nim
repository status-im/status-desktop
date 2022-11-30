import NimQml, chronicles, strutils, json, nimcrypto

import ../settings/service as settings_service
import ../node_configuration/service as node_configuration_service

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/fleets/fleet_configuration

include async_tasks

logScope:
  topics = "node-service"

# Signals which may be emitted by this service:
const SIGNAL_BITS_SET_FETCHED* = "bitsSetFetched"
const SIGNAL_NETWORK_DISCONNECTED* = "networkDisconnected"
const SIGNAL_NETWORK_CONNECTED* = "networkConnected"

type
    BitsSet* = ref object of Args
        bitsSet*: int

QtObject:
    type Service* = ref object of QObject
        events*: EventEmitter
        threadpool: ThreadPool
        settingsService: settings_service.Service
        nodeConfigurationService: node_configuration_service.Service
        bloomBitsSet: int
        peers*: seq[string]
        connected: bool

    proc delete*(self: Service) =
       self.QObject.delete

    proc newService*(events: EventEmitter, threadpool: ThreadPool, settingsService: settings_service.Service, nodeConfigurationService: node_configuration_service.Service): Service =
        new(result, delete)
        result.QObject.setup
        result.events = events
        result.threadpool = threadpool
        result.settingsService = settingsService
        result.nodeConfigurationService = nodeConfigurationService
        result.peers = @[]
        result.connected = false

    proc init*(self: Service) =
        discard

    proc bloomFiltersBitsSet*(self: Service, slot: string) =
        let arg = BloomBitsSetTaskArg(
            tptr: cast[ByteAddress](bloomBitsSetTask),
            vptr: cast[ByteAddress](self.vptr),
            slot: slot
        )
        self.threadpool.start(arg)

    proc fetchBitsSet*(self: Service) =
        self.bloomFiltersBitsSet("bitsSet")

    proc getBloomBitsSet*(self: Service): int =
        return self.bloomBitsSet;

    proc bitsSet*(self: Service, bitsSet: string) {.slot.} =
        self.bloomBitsSet = parseInt(bitsSet)
        self.events.emit(SIGNAL_BITS_SET_FETCHED, BitsSet(bitsSet: self.bloomBitsSet))

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
        var fleet = self.nodeConfigurationService.getFleet()
        let isWakuV2 = if fleet == WakuV2Prod or fleet == WakuV2Test or fleet == StatusTest or fleet == StatusProd:
            true 
        else:
            false
        if isWakuV2:
            return wakuV2Peers()
        else:
            return adminPeers()

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