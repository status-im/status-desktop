import json, json_serialization, chronicles, atomics
import options

import ../../../backend/network as status_network
import ./service_interface

export service_interface


logScope:
  topics = "network-service"

type 
  Service* = ref object of ServiceInterface
    networks: seq[NetworkDto]
    networksInited: bool
    dirty: Atomic[bool]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

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

method upsertNetwork*(self: Service, network: NetworkDto) =
  discard status_network.upsertNetwork(network.toPayload())
  self.dirty.store(true)

method deleteNetwork*(self: Service, network: NetworkDto) =
  discard status_network.deleteNetwork(%* [network.chainId])
  self.dirty.store(true) 

method getNetwork*(self: Service, networkType: NetworkType): NetworkDto =
  for network in self.getNetworks():
    if networkType.toChainId() == network.chainId:
      return network

  # Will be removed, this is used in case of legacy chain Id
  return NetworkDto(chainId: networkType.toChainId())
