import json, json_serialization, chronicles, atomics

import ../../../app/core/eventemitter
import ../../../backend/backend as backend
import ../settings/service as settings_service

import dto, types

export dto, types

logScope:
  topics = "network-service"

type 
  Service* = ref object of RootObj
    events: EventEmitter
    networks: seq[NetworkDto]
    networksInited: bool
    dirty: Atomic[bool]
    settingsService: settings_service.Service


proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, settingsService: settings_service.Service): Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService

proc init*(self: Service) =
  discard

proc fetchNetworks*(self: Service, useCached: bool = true): seq[NetworkDto] =
  let cacheIsDirty = not self.networksInited or self.dirty.load
  if useCached and not cacheIsDirty:
    result = self.networks
  else:
    let response = backend.getEthereumChains(false)
    if not response.error.isNil:
      raise newException(Exception, "Error getting networks: " & response.error.message)
    result = if response.result.isNil or response.result.kind == JNull: @[]
              else: Json.decode($response.result, seq[NetworkDto])
    self.dirty.store(false)
    self.networks = result
    self.networksInited = true

proc getNetworks*(self: Service): seq[NetworkDto] = 
  let testNetworksEnabled = self.settingsService.areTestNetworksEnabled()
    
  for network in self.fetchNetworks():
    if testNetworksEnabled and network.isTest:
      result.add(network)
      
    if not testNetworksEnabled and not network.isTest:
      result.add(network)

proc upsertNetwork*(self: Service, network: NetworkDto) =
  discard backend.addEthereumChain(backend.Network(
    chainId: network.chainId,
    nativeCurrencyDecimals: network.nativeCurrencyDecimals,
    layer: network.layer,
    chainName: network.chainName,
    rpcURL: network.rpcURL,
    blockExplorerURL: network.blockExplorerURL,
    iconURL: network.iconURL,
    nativeCurrencyName: network.nativeCurrencyName,
    nativeCurrencySymbol: network.nativeCurrencySymbol,
    isTest: network.isTest,
    enabled: network.enabled,
    chainColor: network.chainColor,
    shortName: network.shortName,
  ))
  self.dirty.store(true)

proc deleteNetwork*(self: Service, network: NetworkDto) =
  discard backend.deleteEthereumChain(network.chainId)
  self.dirty.store(true)

proc getNetwork*(self: Service, chainId: int): NetworkDto =
  for network in self.fetchNetworks():
    if chainId == network.chainId:
      return network

proc getNetwork*(self: Service, networkType: NetworkType): NetworkDto =
  for network in self.fetchNetworks():
    if networkType.toChainId() == network.chainId:
      return network

  # Will be removed, this is used in case of legacy chain Id
  return NetworkDto(chainId: networkType.toChainId())

proc toggleNetwork*(self: Service, chainId: int) =
  let network = self.getNetwork(chainId)

  network.enabled = not network.enabled
  self.upsertNetwork(network)

proc getNetworkForEns*(self: Service): NetworkDto =
  if self.settingsService.areTestNetworksEnabled():
    return self.getNetwork(Ropsten)

  return self.getNetwork(Mainnet)

proc getNetworkForStickers*(self: Service): NetworkDto =
    return self.getNetworkForEns()

proc getNetworkForBrowser*(self: Service): NetworkDto =
    return self.getNetworkForEns()

proc getNetworkForChat*(self: Service): NetworkDto =
    return self.getNetworkForEns()

proc getNetworkForCollectibles*(self: Service): NetworkDto =
  if self.settingsService.areTestNetworksEnabled():
    return self.getNetwork(Rinkeby)

  return self.getNetwork(Mainnet)
