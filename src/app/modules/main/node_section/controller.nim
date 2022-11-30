import json, strutils
import io_interface

import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/node_configuration/service as node_configuration_service

import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../core/fleets/fleet_configuration

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    nodeService: node_service.Service
    nodeConfigurationService: node_configuration_service.Service
    isWakuV2: bool

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeService: node_service.Service,
  nodeConfigurationService: node_configuration_service.Service
  ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.nodeService = nodeService
  result.nodeConfigurationService = nodeConfigurationService

proc delete*(self: Controller) =
   discard

proc setPeers(self: Controller, peers: seq[string]) =
  self.nodeService.peerSummaryChange(peers)
  self.delegate.setPeerSize(peers.len)

proc init*(self: Controller) =
  self.isWakuV2 = self.nodeConfigurationService.getWakuVersion() == WAKU_VERSION_2

  self.events.on(SignalType.Wallet.event) do(e:Args):
    self.delegate.setLastMessage($WalletSignal(e).blockNumber)

  self.events.on(SignalType.DiscoverySummary.event) do(e:Args):
    var data = DiscoverySummarySignal(e)
    self.setPeers(data.enodes)

  self.events.on(SignalType.PeerStats.event) do(e:Args):
    var data = PeerStatsSignal(e)
    self.setPeers(data.peers)

  self.events.on(SignalType.Stats.event) do (e:Args):
    self.delegate.setStats(StatsSignal(e).stats)
    if not self.isWakuV2: self.delegate.fetchBitsSet()

  self.events.on(SignalType.ChroniclesLogs.event) do(e:Args):
    self.delegate.log(ChroniclesLogsSignal(e).content)

  self.events.on(SIGNAL_BITS_SET_FETCHED) do (e:Args):
    self.delegate.setBitsSet(self.nodeService.getBloomBitsSet())

  self.setPeers(self.nodeService.fetchPeers())

proc sendRPCMessageRaw*(self: Controller, inputJSON: string): string =
   return self.nodeService.sendRPCMessageRaw(inputJSON);

proc setBloomFilterMode*(self: Controller, bloomFilterMode: bool): bool =
   return self.nodeConfigurationService.setBloomFilterMode(bloomFilterMode)

proc setBloomLevel*(self: Controller, level: string): bool =
   return self.nodeConfigurationService.setBloomLevel(level)

proc isV2LightMode*(self: Controller): bool =
   return self.nodeConfigurationService.isV2LightMode()

proc isFullNode*(self: Controller): bool =
   return self.nodeConfigurationService.isFullNode()

proc setV2LightMode*(self: Controller, enabled: bool): bool =
   return self.nodeConfigurationService.setV2LightMode(enabled)

proc getWakuBloomFilterMode*(self: Controller): bool =
    return self.settingsService.getWakuBloomFilterMode()

proc fetchBitsSet*(self: Controller) =
    self.nodeService.fetchBitsSet()

proc getWakuVersion*(self: Controller): int =
    var fleet = self.nodeConfigurationService.getFleet()
    let isWakuV2 = if fleet == WakuV2Prod or fleet == WakuV2Test or fleet == StatusTest or fleet == StatusProd: 
      true 
    else:
      false
    if isWakuV2: return 2
    return 1

proc getBloomLevel*(self: Controller): string =
    return self.nodeConfigurationService.getBloomLevel()
