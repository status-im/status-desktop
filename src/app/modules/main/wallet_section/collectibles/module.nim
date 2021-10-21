import eventemitter

import ./io_interface, ./controller
import ../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./collectible/module as collectible_module
import ./collections/module as collections_module
import ./collectibles/module as collectibles_module

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    moduleLoaded: bool
    controller: controller.AccessInterface

    collectiblesModule: collectibles_module.AccessInterface
    collectionsModule: collections_module.AccessInterface
    collectibleModule: collectible_module.AccessInterface

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  collectibleService: collectible_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.controller = newController(result, walletAccountService)
  result.moduleLoaded = false

  result.collectiblesModule = collectibles_module.newModule[Module[T]](
    result, collectibleService
  )
  result.collectionsModule = collectionsModule.newModule[Module[T]](
    result, collectibleService
  )
  result.collectibleModule = collectibleModule.newModule[Module[T]](
    result, collectibleService
  )

method delete*[T](self: Module[T]) =
  self.collectiblesModule.delete
  self.collectionsModule.delete
  self.collectibleModule.delete

method load*[T](self: Module[T]) =
  self.collectiblesModule.load
  self.collectionsModule.load
  self.collectibleModule.load

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method switchAccount*[T](self: Module[T], accountIndex: int) =
  let account = self.controller.getWalletAccount(accountIndex)
  self.collectionsModule.loadCollections(account.address)