import json, json_serialization, chronicles, sugar, sequtils

import ../../../app/core/eventemitter
import ../../../backend/backend as backend
import ../settings/service as settings_service
import ./network_item, ./combined_network_item

import dto, types

export dto, types

logScope:
  topics = "network-service"

const SIGNAL_NETWORK_ENDPOINT_UPDATED* = "networkEndPointUpdated"
const EXPLORER_TX_PATH* = "/tx"
const EXPLORER_ADDRESS_PATH* = "/address"

type NetworkEndpointUpdatedArgs* = ref object of Args
  isTest*: bool
  networkName*: string
  revertedToDefault*: bool

type Service* = ref object of RootObj
  events: EventEmitter
  combinedNetworks: seq[CombinedNetworkItem]
  flatNetworks: seq[NetworkItem]
  settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(
    events: EventEmitter, settingsService: settings_service.Service
): Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService

proc fetchNetworks*(self: Service): seq[CombinedNetworkItem] =
  let response = backend.getEthereumChains()
  if not response.error.isNil:
    raise newException(
      Exception, "Error getting combinedNetworks: " & response.error.message
    )
  let combinedNetworksDto =
    if response.result.isNil or response.result.kind == JNull:
      @[]
    else:
      Json.decode($response.result, seq[CombinedNetworkDto], allowUnknownFields = true)
  result = combinedNetworksDto.map(x => x.combinedNetworkDtoToCombinedItem())
  self.combinedNetworks = result
  let allTestEnabled =
    self.combinedNetworks.filter(n => n.test.isEnabled).len == self.combinedNetworks.len
  let allProdEnabled =
    self.combinedNetworks.filter(n => n.prod.isEnabled).len == self.combinedNetworks.len
  for n in self.combinedNetworks:
    n.test.enabledState =
      networkEnabledToUxEnabledState(n.test.isEnabled, allTestEnabled)
    n.prod.enabledState =
      networkEnabledToUxEnabledState(n.prod.isEnabled, allProdEnabled)
  self.flatNetworks = @[]
  for network in self.combinedNetworks:
    self.flatNetworks.add(network.test)
    self.flatNetworks.add(network.prod)

proc init*(self: Service) =
  discard self.fetchNetworks()

proc resetNetworks*(self: Service) =
  discard self.fetchNetworks()

proc getCombinedNetworks*(self: Service): var seq[CombinedNetworkItem] =
  return self.combinedNetworks

proc getFlatNetworks*(self: Service): var seq[NetworkItem] =
  return self.flatNetworks

# passes networks based on users choice of test/mainnet
proc getCurrentNetworks*(self: Service): seq[NetworkItem] =
  let testEnabled = self.settingsService.areTestNetworksEnabled()
  self.flatNetworks.filter(n => n.isTest == testEnabled)

proc getCurrentNetworksChainIds*(self: Service): seq[int] =
  return self.getCurrentNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Service): seq[int] =
  return self.getCurrentNetworks().filter(n => n.isEnabled).map(n => n.chainId)

proc upsertNetwork*(self: Service, network: NetworkItem): bool =
  let response = backend.addEthereumChain(
    backend.Network(
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
      enabled: network.isEnabled,
      chainColor: network.chainColor,
      shortName: network.shortName,
      relatedChainID: network.relatedChainId,
    )
  )
  return response.error == nil

proc deleteNetwork*(self: Service, network: NetworkItem) =
  discard backend.deleteEthereumChain(network.chainId)

proc getNetworkByChainId*(
    self: Service, chainId: int, testNetworksEnabled: bool
): NetworkItem =
  var networks = self.combinedNetworks
  if self.combinedNetworks.len == 0:
    networks = self.fetchNetworks()
  for network in networks:
    let net = if testNetworksEnabled: network.test else: network.prod
    if chainId == net.chainId:
      return net
  return nil

proc getNetworkByChainId*(self: Service, chainId: int): NetworkItem =
  return
    self.getNetworkByChainId(chainId, self.settingsService.areTestNetworksEnabled())

proc setNetworksState*(self: Service, chainIds: seq[int], enabled: bool) =
  for chainId in chainIds:
    let network = self.getNetworkByChainId(chainId)

    if not network.isNil:
      if network.isEnabled == enabled:
        continue

      network.isEnabled = enabled
      discard self.upsertNetwork(network)
  discard self.fetchNetworks()

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
proc getAppNetwork*(self: Service): NetworkItem =
  var networkId = Mainnet
  if self.settingsService.areTestNetworksEnabled():
    networkId = Sepolia
  let network = self.getNetworkByChainId(networkId)
  if network.isNil:
    # we should not be here ever
    error "the app network cannot be resolved"
    quit() # quit the app
  return network

proc updateNetworkEndPointValues*(
    self: Service,
    chainId: int,
    testNetwork: bool,
    newMainRpcInput, newFailoverRpcUrl: string,
    revertToDefault: bool,
) =
  let network = self.getNetworkByChainId(chainId, testNetwork)

  if not network.isNil:
    if network.rpcURL != newMainRpcInput:
      network.rpcURL = newMainRpcInput

    if network.fallbackURL != newFailoverRpcUrl:
      network.fallbackURL = newFailoverRpcUrl

    if self.upsertNetwork(network):
      self.events.emit(
        SIGNAL_NETWORK_ENDPOINT_UPDATED,
        NetworkEndpointUpdatedArgs(
          isTest: network.isTest,
          networkName: network.chainName,
          revertedToDefault: revertToDefault,
        ),
      )
