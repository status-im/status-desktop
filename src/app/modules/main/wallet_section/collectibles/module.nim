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

method fetchOwnedCollectibles*(self: Module, limit: int) =
  self.controller.fetchOwnedCollectibles(self.chainId, self.address, limit)

method switchAccount*(self: Module, accountIndex: int) =
  let network = self.controller.getNetwork()
  let account = self.controller.getWalletAccount(accountIndex)

  self.chainId = network.chainId
  self.address = account.address

  # TODO: Implement a way to reduce the number of full re-fetches. It could be only
  # when NFT activity was detected for the given account, or if a certain amount of
  # time has passed. For now, we fetch every time we select the account.
  self.controller.resetOwnedCollectibles(self.chainId, self.address)

  self.controller.refreshCollectibles(self.chainId, self.address)

  self.currentCollectibleModule.setCurrentAddress(network, self.address)

method refreshCollectibles*(self: Module, chainId: int, address: string, collectibles: CollectiblesData) =
  if self.chainId == chainId and self.address == address:
    var idsToAdd = newSeq[UniqueID]()
    let append = not collectibles.lastLoadWasFromStart

    var startIdx = 0
    if append:
      for i in collectibles.ids.len - collectibles.lastLoadCount ..< collectibles.ids.len:
        idsToAdd.add(collectibles.ids[i])
    else:
      idsToAdd = collectibles.ids

    var newCollectibles = idsToAdd.map(id => (block:
        let c = self.controller.getCollectible(self.chainId, id)
        let co = self.controller.getCollection(self.chainId, c.collectionSlug)
        return collectibleToItem(c, co)
      ))
    self.view.setCollectibles(newCollectibles, append, collectibles.allLoaded)

method noConnectionToOpenSea*(self: Module) =
   self.view.noConnectionToOpenSea()

