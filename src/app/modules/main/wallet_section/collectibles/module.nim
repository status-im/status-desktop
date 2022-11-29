import ./io_interface, ./controller
import ../io_interface as delegate_interface
import ../../../../core/eventemitter
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./collections/module as collections_module
import ./collectibles/module as collectibles_module
import ./current_collectible/module as current_collectible_module

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    moduleLoaded: bool
    controller: Controller

    collectiblesModule: collectibles_module.AccessInterface
    collectionsModule: collections_module.AccessInterface
    currentCollectibleModule: current_collectible_module.AccessInterface

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  collectibleService: collectible_service.Service,
  walletAccountService: wallet_account_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

  result.collectiblesModule = collectibles_module.newModule(result, events, collectibleService)
  result.collectionsModule = collectionsModule.newModule(result, events, collectibleService)
  result.currentCollectibleModule = currentCollectibleModule.newModule(result, collectibleService, result.collectionsModule, result.collectiblesModule)

method delete*(self: Module) =
  self.collectiblesModule.delete
  self.collectionsModule.delete
  self.currentCollectibleModule.delete

method load*(self: Module) =
  self.controller.init
  self.collectiblesModule.load
  self.collectionsModule.load
  self.currentCollectibleModule.load

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.collectiblesModule.isLoaded()):
    return

  if(not self.collectionsModule.isLoaded()):
    return

  if(not self.currentCollectibleModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.collectiblesModuleDidLoad()

method collectiblesModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method collectionsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method currentCollectibleModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method switchAccount*(self: Module, accountIndex: int) =
  let account = self.controller.getWalletAccount(accountIndex)
  self.collectionsModule.loadCollections(account.address)
  self.collectiblesModule.setCurrentAddress(account.address)
