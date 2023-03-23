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

    currentCollectibleModule: current_collectible_module.AccessInterface
    chainId: int
    address: string

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
  self.controller.fetchOwnedCollectibles(self.chainId, self.address)

method switchAccount*(self: Module, accountIndex: int) =
  let network = self.controller.getNetwork()
  let account = self.controller.getWalletAccount(accountIndex)

  self.chainId = network.chainId
  self.address = account.address

  self.currentCollectibleModule.setCurrentAddress(network, self.address)

  let data = self.controller.getOwnedCollectibles(self.chainId, self.address)

  # Trigger a fetch the first time we switch to an account
  if not data.anyLoaded:
    self.controller.fetchOwnedCollectibles(self.chainId, self.address)

  self.setCollectibles(self.chainId, self.address, data)

proc ownedCollectibleToItem(self: Module, oc: OwnedCollectible): Item =
  let c = self.controller.getCollectible(self.chainId, oc.id)
  let col = self.controller.getCollection(self.chainId, c.collectionSlug)
  return collectibleToItem(c, col, oc.isFromWatchedContract)

method onFetchStarted*(self: Module, chainId: int, address: string) =
  if self.chainId == chainId and self.address == address:
    self.view.setIsFetching(true)

method setCollectibles*(self: Module, chainId: int, address: string, data: CollectiblesData) =
  if self.chainId == chainId and self.address == address:
    self.view.setIsFetching(data.isFetching)
    var newCollectibles = data.collectibles.map(oc => self.ownedCollectibleToItem(oc))
    self.view.setCollectibles(newCollectibles)
    self.view.setAllLoaded(data.allLoaded)

method appendCollectibles*(self: Module, chainId: int, address: string, data: CollectiblesData) =
  if self.chainId == chainId and self.address == address:
    self.view.setIsFetching(data.isFetching)

    var ownedCollectiblesToAdd = newSeq[OwnedCollectible]()
    for i in data.collectibles.len - data.lastLoadCount ..< data.collectibles.len:
      ownedCollectiblesToAdd.add(data.collectibles[i])

    let newCollectibles = ownedCollectiblesToAdd.map(oc => self.ownedCollectibleToItem(oc))

    self.view.appendCollectibles(newCollectibles)
    self.view.setAllLoaded(data.allLoaded)

method connectionToOpenSea*(self: Module, connected: bool) =
   self.view.connectionToOpenSea(connected)
