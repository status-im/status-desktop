import NimQml, Tables, sequtils, sugar

import ../../../../global/global_singleton
import ../../../../core/eventemitter

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/collectible/service as collectible_dto
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service

import ./current_collectible/module as current_collectible_module

import ./models/collectibles_item as collectibles_item
import ./models/collectible_trait_item as collectible_trait_item
import ./models/collections_item as collections_item

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
  networkService: network_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, events, collectibleService, walletAccountService, networkService)
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

method switchAccount*(self: Module, accountIndex: int) =
  let network = self.controller.getNetwork()
  let account = self.controller.getWalletAccount(accountIndex)

  self.chainId = network.chainId
  self.address = account.address

  self.controller.refreshCollections(self.chainId, self.address)
  self.controller.fetchCollections(self.chainId, self.address)

  self.currentCollectibleModule.setCurrentAddress(network, self.address)

proc collectibleToItem(c: collectible_dto.CollectibleDto) : collectibles_item.Item =
  return collectibles_item.initItem(
    c.id,
    c.name,
    c.imageUrl,
    c.backgroundColor,
    c.description,
    c.permalink,
    c.properties.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.rankings.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.statistics.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue))
  )

proc collectionToItem(c: CollectionData) : collections_item.Item =
  return collections_item.initItem(
      c.collection.name,
      c.collection.slug,
      c.collection.imageUrl,
      c.collection.ownedAssetCount,
      c.collectiblesLoaded,
      toSeq(c.collectibles.values).map(c => collectibleToItem(c))
  )

method setCollections*(self: Module, collections: CollectionsData) =
  self.view.setCollections(
    toSeq(collections.collections.values).map(c => collectionToItem(c))
  )

method updateCollection*(self: Module, collection: CollectionData) =
  self.view.setCollectibles(collection.collection.slug,
    toSeq(collection.collectibles.values).map(c => collectibleToItem(c))
  )

method fetchCollections*(self: Module) =
  self.controller.fetchCollections(self.chainId, self.address)

method fetchCollectibles*(self: Module, collectionSlug: string) =
  self.controller.fetchCollectibles(self.chainId, self.address, collectionSlug)
