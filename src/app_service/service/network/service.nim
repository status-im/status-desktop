import json, json_serialization, chronicles, atomics

import ../../../app/core/eventemitter
import ../../../backend/backend as backend
import ../settings/service as settings_service

import dto, types

export dto, types

logScope:
  topics = "network-service"

const SIGNAL_NETWORK_ENDPOINT_UPDATED* = "networkEndPointUpdated"

type NetworkEndpointUpdatedArgs* = ref object of Args
  isTest*: bool
  networkName*: string
  revertedToDefault*: bool

type
  Service* = ref object of RootObj
    events: EventEmitter
    networks: seq[CombinedNetworkDto]
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

proc fetchNetworks*(self: Service, useCached: bool = true): seq[CombinedNetworkDto] =
  let cacheIsDirty = not self.networksInited or self.dirty.load
  if useCached and not cacheIsDirty:
    result = self.networks
  else:
    let response = backend.getEthereumChains()
    if not response.error.isNil:
      raise newException(Exception, "Error getting networks: " & response.error.message)
    result = if response.result.isNil or response.result.kind == JNull: @[]
              else: Json.decode($response.result, seq[CombinedNetworkDto], allowUnknownFields = true)
    self.dirty.store(false)
    self.networks = result
    self.networksInited = true

proc resetNetworks*(self: Service) =
  discard self.fetchNetworks(useCached = false)

proc getCombinedNetworks*(self: Service): seq[CombinedNetworkDto] =
  return self.fetchNetworks()

# TODO:: update the networks service to unify the model exposed from this service
# We currently have 3 types: combined, test/mainet and flat and probably can be optimized
# follow up task https://github.com/status-im/status-desktop/issues/12717
proc getFlatNetworks*(self: Service): seq[NetworkDto] =
  for network in self.fetchNetworks():
      result.add(network.test)
      result.add(network.prod)

proc getNetworks*(self: Service): seq[NetworkDto] =
  let testNetworksEnabled = self.settingsService.areTestNetworksEnabled()

  for network in self.fetchNetworks():
    if testNetworksEnabled:
      result.add(network.test)
    else:
      result.add(network.prod)

proc getAllNetworkChainIds*(self: Service): seq[int] =
  for network in self.fetchNetworks():
      result.add(network.test.chainId)
      result.add(network.prod.chainId)

proc upsertNetwork*(self: Service, network: NetworkDto): bool =
  let response = backend.addEthereumChain(backend.Network(
    chainId: network.chainId,
    nativeCurrencyDecimals: network.nativeCurrencyDecimals,
    layer: network.layer,
    chainName: network.chainName,
    rpcURL: network.rpcURL,
    originalRpcURL: network.originalRpcURL,
    fallbackURL: network.fallbackURL,
    originalFallbackURL: network.originalFallbackURL,
    blockExplorerURL: network.blockExplorerURL,
    iconURL: network.iconURL,
    nativeCurrencyName: network.nativeCurrencyName,
    nativeCurrencySymbol: network.nativeCurrencySymbol,
    isTest: network.isTest,
    enabled: network.enabled,
    chainColor: network.chainColor,
    shortName: network.shortName,
    relatedChainID: network.relatedChainID,
  ))
  self.dirty.store(true)
  return response.error == nil

proc deleteNetwork*(self: Service, network: NetworkDto) =
  discard backend.deleteEthereumChain(network.chainId)
  self.dirty.store(true)

proc getNetwork*(self: Service, chainId: int): NetworkDto =
  let testNetworksEnabled = self.settingsService.areTestNetworksEnabled()
  for network in self.fetchNetworks():
    let net = if testNetworksEnabled: network.test
              else: network.prod
    if chainId == net.chainId:
        return net

proc getNetworkByChainId*(self: Service, chainId: int): NetworkDto =
  for network in self.fetchNetworks():
    if chainId == network.prod.chainId:
        return network.prod
    elif chainId == network.test.chainId:
       return  network.test

proc getNetwork*(self: Service, networkType: NetworkType): NetworkDto =
  let testNetworksEnabled = self.settingsService.areTestNetworksEnabled()
  for network in self.fetchNetworks():
    let net = if testNetworksEnabled: network.test
              else: network.prod
    if networkType.toChainId() == net.chainId:
      return net

  # Will be removed, this is used in case of legacy chain Id
  return NetworkDto(chainId: networkType.toChainId())

proc setNetworksState*(self: Service, chainIds: seq[int], enabled: bool) =
  for chainId in chainIds:
    let network = self.getNetwork(chainId)

    if network.enabled == enabled:
      continue

    network.enabled = enabled
    discard self.upsertNetwork(network)

## This procedure retuns the network to be used based on the app mode (testnet/mainnet).
## We don't need to check if retuned network is nil cause it should never be, but if somehow it is, the app will be closed.
##
## Should be used for:
## - Stickers
## - Chat
## - Activity check
## - Collectibles
## - ENS names
## - Browser
proc getAppNetwork*(self: Service): NetworkDto =
  var networkId = Mainnet
  if self.settingsService.areTestNetworksEnabled():
    networkId = Sepolia
    if self.settingsService.isGoerliEnabled():
      networkId = Goerli
  let network = self.getNetwork(networkId)
  if network.isNil:
    # we should not be here ever
    error "the app network cannot be resolved"
    quit() # quit the app
  return network

proc updateNetworkEndPointValues*(self: Service, chainId: int, newMainRpcInput, newFailoverRpcUrl: string, revertToDefault: bool) =
  let network = self.getNetworkByChainId(chainId)

  if network.rpcURL != newMainRpcInput:
    network.rpcURL = newMainRpcInput

  if network.fallbackURL != newFailoverRpcUrl:
    network.fallbackURL = newFailoverRpcUrl

  if self.upsertNetwork(network):
    self.events.emit(SIGNAL_NETWORK_ENDPOINT_UPDATED, NetworkEndpointUpdatedArgs(isTest: network.isTest, networkName: network.chainName, revertedToDefault: revertToDefault))
