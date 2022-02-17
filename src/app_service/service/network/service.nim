import json, json_serialization, chronicles, atomics

import ../../../app/core/eventemitter
import ../../../app/global/global_singleton
import ../../../backend/network as status_network
import ../settings/service as settings_service
import ./service_interface as network_interface

export network_interface


logScope:
  topics = "network-service"

type 
  Service* = ref object of network_interface.ServiceInterface
    events: EventEmitter
    networks: seq[NetworkDto]
    networksInited: bool
    dirty: Atomic[bool]
    settingsService: settings_service.Service


method delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, settingsService: settings_service.Service): Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService

method init*(self: Service) =
  discard

method getNetworks*(self: Service, useCached: bool = true): seq[NetworkDto] =
  let cacheIsDirty = not self.networksInited or self.dirty.load
  if useCached and not cacheIsDirty:
    result = self.networks
  else:
    let payload = %* [false]
    let response = status_network.getNetworks(payload)
    if not response.error.isNil:
      raise newException(Exception, "Error getting networks: " & response.error.message)
    result =  if response.result.isNil or response.result.kind == JNull: @[]
              else: Json.decode($response.result, seq[NetworkDto])
    self.dirty.store(false)
    self.networks = result
    self.networksInited = true

method getEnabledNetworks*(self: Service): seq[NetworkDto] =
  if not singletonInstance.localAccountSensitiveSettings.getIsMultiNetworkEnabled():
    let currentNetworkType = self.settingsService.getCurrentNetwork().toNetworkType()
    for network in self.getNetworks():
      if currentNetworkType.toChainId() == network.chainId:
        return @[network]

  let networks = self.getNetworks()
  for network in networks:
    if network.enabled:
      result.add(network)  

method upsertNetwork*(self: Service, network: NetworkDto) =
  discard status_network.upsertNetwork(network.toPayload())
  self.dirty.store(true)

method deleteNetwork*(self: Service, network: NetworkDto) =
  discard status_network.deleteNetwork(%* [network.chainId])
  self.dirty.store(true)

method getNetwork*(self: Service, chainId: int): NetworkDto =
  for network in self.getNetworks():
    if chainId == network.chainId:
      return network

method getNetwork*(self: Service, networkType: NetworkType): NetworkDto =
  for network in self.getNetworks():
    if networkType.toChainId() == network.chainId:
      return network

  # Will be removed, this is used in case of legacy chain Id
  return NetworkDto(chainId: networkType.toChainId())

method toggleNetwork*(self: Service, chainId: int) =
  let network = self.getNetwork(chainId)

  network.enabled = not network.enabled
  self.upsertNetwork(network)