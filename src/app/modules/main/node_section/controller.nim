import json, strutils
import controller_interface
import io_interface

import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/node/service as node_service
import ../../../../app_service/service/node_configuration/service as node_configuration_service

import eventemitter
import ../../../core/signals/types
import ../../../core/fleets/fleet_configuration

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    nodeService: node_service.Service
    nodeConfigurationService: node_configuration_service.ServiceInterface
    isWakuV2: bool

proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  nodeService: node_service.Service,
  nodeConfigurationService: node_configuration_service.ServiceInterface
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

method init*(self: Controller) = 
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

method sendRPCMessageRaw*(self: Controller, inputJSON: string): string =
   return self.nodeService.sendRPCMessageRaw(inputJSON);

method setBloomFilterMode*(self: Controller, bloomFilterMode: bool): bool =
   return self.nodeConfigurationService.setBloomFilterMode(bloomFilterMode)

method setBloomLevel*(self: Controller, level: string): bool =
   return self.nodeConfigurationService.setBloomLevel(level)

method isV2LightMode*(self: Controller): bool =
   return self.nodeConfigurationService.isV2LightMode()

method isFullNode*(self: Controller): bool =
   return self.nodeConfigurationService.isFullNode()

method setV2LightMode*(self: Controller, enabled: bool): bool =
   return self.nodeConfigurationService.setV2LightMode(enabled)

method getWakuBloomFilterMode*(self: Controller): bool =
    return self.settingsService.getWakuBloomFilterMode()

method fetchBitsSet*(self: Controller) =
    self.nodeService.fetchBitsSet()

method getWakuVersion*(self: Controller): int =
    var fleet = self.settingsService.getFleet()
    let isWakuV2 = if fleet == WakuV2Prod or fleet == WakuV2Test: true else: false
    if isWakuV2: return 2
    return 1

method getBloomLevel*(self: Controller): string =
    return self.nodeConfigurationService.getBloomLevel()
