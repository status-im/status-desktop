import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/node/service as node_service
import ../../../../../app_service/service/network_connection/service as network_connection_service

import ./current_collectible/module as current_collectible_module

import ./models/collectibles_item as collectibles_item
import ./models/collectible_trait_item as collectible_trait_item
import ./models/collectibles_utils
import ./models/collectibles_model as collectibles_model

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool

    chainId: int
    addresses: seq[string]

    currentCollectibleModule: current_collectible_module.AccessInterface

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  nodeService: node_service.Service,
  networkConnectionService: network_connection_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, events, collectibleService, walletAccountService, networkService, nodeService, networkConnectionService)
  result.moduleLoaded = false
  result.chainId = 0
  result.addresses = @[]
  result.currentCollectibleModule = currentCollectibleModule.newModule(result, collectibleService)

method delete*(self: Module) =
  self.view.delete
  self.currentCollectibleModule.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCollectibles", newQVariant(self.view))
  self.controller.init()
  self.view.load()
  
  self.currentCollectibleModule.load

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if self.moduleLoaded:
    return

  if(not self.currentCollectibleModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.collectiblesModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method currentCollectibleModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method fetchOwnedCollectibles*(self: Module) =
  self.controller.fetchOwnedCollectibles(self.chainId, self.addresses)

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  let network = self.controller.getNetwork()
  self.chainId = network.chainId
  self.addresses = addresses
  self.currentCollectibleModule.setCurrentNetwork(network)
  self.view.setCollectibles(@[])
  let data = self.controller.getOwnedCollectibles(self.chainId, self.addresses)

  for i, addressData in data.pairs:
    if not addressData.anyLoaded:
      self.controller.fetchOwnedCollectibles(self.chainId, @[self.addresses[i]])

  self.setCollectibles(data)

proc ownedCollectibleToItem(self: Module, oc: OwnedCollectible): Item =
  let c = self.controller.getCollectible(self.chainId, oc.id)
  let col = self.controller.getCollection(self.chainId, c.collectionSlug)
  return collectibleToItem(c, col, oc.isFromWatchedContract)

method onFetchStarted*(self: Module, chainId: int, address: string) =
  if self.chainId == chainId and address in self.addresses:
    self.view.setIsFetching(true)

method resetCollectibles*(self: Module) =
  let data = self.controller.getOwnedCollectibles(self.chainId, self.addresses)
  self.setCollectibles(data)

method appendCollectibles*(self: Module, chainId: int, address: string, data: CollectiblesData) =
  if not (self.chainId == chainId and address in self.addresses):
    return

  self.view.setIsError(data.isError)

  if data.isError and not data.anyLoaded:
    # If fetching failed before being able to get any collectibles info,
    # show loading animation
    self.view.setIsFetching(true)
  else:
    self.view.setIsFetching(data.isFetching)

  if data.lastLoadCount > 0:
    var ownedCollectiblesToAdd = newSeq[OwnedCollectible]()
    for i in data.collectibles.len - data.lastLoadCount ..< data.collectibles.len:
      ownedCollectiblesToAdd.add(data.collectibles[i])

    let newCollectibles = ownedCollectiblesToAdd.map(oc => self.ownedCollectibleToItem(oc))

    self.view.appendCollectibles(newCollectibles)

  self.view.setAllLoaded(data.allLoaded)

method setCollectibles*(self: Module, data: seq[CollectiblesData]) =
  for index, address in self.addresses:
    self.appendCollectibles(self.chainId, address, data[index])

method getHasCollectiblesCache*(self: Module): bool =
  return self.controller.getHasCollectiblesCache(self.addresses[0])