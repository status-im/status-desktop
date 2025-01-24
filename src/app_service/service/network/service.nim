import json, json_serialization, chronicles, sugar, sequtils

import ../../../app/core/eventemitter
import backend/network as backend
import ../settings/service as settings_service
import ./network_item, ./combined_network_item

import types
export types

logScope:
  topics = "network-service"

const SIGNAL_NETWORK_ENDPOINT_UPDATED* = "networkEndPointUpdated"
const EXPLORER_TX_PATH* = "/tx"
const EXPLORER_ADDRESS_PATH* = "/address"

type NetworkEndpointUpdatedArgs* = ref object of Args
  isTest*: bool
  networkName*: string

type
  Service* = ref object of RootObj
    events: EventEmitter
    combinedNetworks: seq[CombinedNetworkItem]
    flatNetworks: seq[NetworkItem]
    rpcProviders: seq[RpcProviderItem]
    settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, settingsService: settings_service.Service): Service =
  result = Service()
  result.events = events
  result.settingsService = settingsService

proc fetchNetworks*(self: Service) =
  let response = backend.getEthereumChains()
  if not response.error.isNil:
    raise newException(Exception, "Error getting combinedNetworks: " & response.error.message)
  let combinedNetworksDto = if response.result.isNil or response.result.kind == JNull: @[]
            else: Json.decode($response.result, seq[CombinedNetworkDto], allowUnknownFields = true)
  self.combinedNetworks = combinedNetworksDtoToCombinedItem(combinedNetworksDto)
  self.flatNetworks = @[]
  for network in self.combinedNetworks:
    self.flatNetworks.add(network.test)
    self.flatNetworks.add(network.prod)
  self.rpcProviders = @[]
  for network in self.flatNetworks:
    for rpcProvider in network.rpcProviders:
      self.rpcProviders.add(rpcProvider)

proc init*(self: Service) =
  self.fetchNetworks()

proc resetNetworks*(self: Service) =
  self.fetchNetworks()

proc getCombinedNetworks*(self: Service): var seq[CombinedNetworkItem] =
  return self.combinedNetworks

proc getFlatNetworks*(self: Service): var seq[NetworkItem] =
  return self.flatNetworks

proc getRpcProviders*(self: Service): var seq[RpcProviderItem] =
  return self.rpcProviders

# passes networks based on users choice of test/mainnet
proc getCurrentNetworks*(self: Service): seq[NetworkItem] =
  let testEnabled = self.settingsService.areTestNetworksEnabled()
  self.flatNetworks.filter(n => n.isTest == testEnabled)

proc getCurrentNetworksChainIds*(self: Service): seq[int] =
  return self.getCurrentNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Service): seq[int] =
  return self.getCurrentNetworks().filter(n => n.isEnabled).map(n => n.chainId)

proc getDisabledChainIdsForEnabledChainIds*(self: Service, enabledChainIds: seq[int]): seq[int] =
  for network in self.getCurrentNetworks():
    if not enabledChainIds.contains(network.chainId):
      result.add(network.chainId)

proc upsertNetwork*(self: Service, network: NetworkItem): bool =
  let response = backend.addEthereumChain(networkItemToDto(network))
  return response.error == nil

proc deleteNetwork*(self: Service, network: NetworkItem) =
  discard backend.deleteEthereumChain(network.chainId)

proc getNetworkByChainId*(self: Service, chainId: int, testNetworksEnabled: bool): NetworkItem =
  var networks = self.combinedNetworks
  if self.combinedNetworks.len == 0:
    self.fetchNetworks()
  for network in self.getCombinedNetworks():
    let net = if testNetworksEnabled: network.test
              else: network.prod
    if chainId == net.chainId:
        return net
  return nil

proc getNetworkByChainId*(self: Service, chainId: int): NetworkItem =
  return self.getNetworkByChainId(chainId, self.settingsService.areTestNetworksEnabled())

proc setNetworksState*(self: Service, chainIds: seq[int], enabled: bool) =
  for chainId in chainIds:
    let network = self.getNetworkByChainId(chainId)

    if not network.isNil:
      discard backend.setChainEnabled(chainId, enabled)
  self.fetchNetworks()

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

proc updateNetworkEndPointValues*(self: Service, chainId: int, testNetwork: bool, newMainRpcInput, newFailoverRpcUrl: string) =
  let network = self.getNetworkByChainId(chainId, testNetwork)

  if not network.isNil:
    var rpcProviders: seq[RpcProviderDto] = @[]
    if newMainRpcInput != "":
      rpcProviders.add(RpcProviderDto(
        id: 1, 
        chainId: chainId, 
        name: "user-rpc-provider-1", 
        url: newMainRpcInput, 
        isRpsLimiterEnabled: false, 
        providerType: RpcProviderType.User, 
        isEnabled: true, 
        authType: RpcProviderAuthType.NoAuth, 
        authLogin: "", 
        authPassword: "", 
        authToken: ""
      ))
    if newFailoverRpcUrl != "":
      rpcProviders.add(RpcProviderDto(
        id: 2, 
        chainId: chainId, 
        name: "user-rpc-provider-2", 
        url: newFailoverRpcUrl, 
        isRpsLimiterEnabled: false, 
        providerType: RpcProviderType.User, 
        isEnabled: true, 
        authType: RpcProviderAuthType.NoAuth, 
        authLogin: "", 
        authPassword: "", 
        authToken: ""
      ))
    let response = backend.setChainUserRpcProviders(chainId, rpcProviders)
    
    if response.error == nil:
      self.fetchNetworks()
      self.events.emit(SIGNAL_NETWORK_ENDPOINT_UPDATED, NetworkEndpointUpdatedArgs(isTest: network.isTest, networkName: network.chainName))
