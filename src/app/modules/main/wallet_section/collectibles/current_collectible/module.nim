import NimQml, sequtils, sugar

import ../../../../../global/global_singleton

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../../app_service/service/network/dto as network_dto
import ../collectibles/module as collectibles_module
import ../collections/module as collections_module

import ../collections/item as collection_item
import ../collectibles/item as collectible_item

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool
    currentAccountIndex: int

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  collectibleService: collectible_service.Service,
  collectionsModule: collections_module.AccessInterface,
  collectiblesModule: collectibles_module.AccessInterface,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, collectibleService, collectiblesModule, collectionsModule)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCollectibleCurrent", newQVariant(self.view))

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.currentCollectibleModuleDidLoad()

method update*(self: Module, slug: string, id: int) =
  self.controller.update(slug, id)

method setData*(self: Module, collection: collection_item.Item, collectible: collectible_item.Item, network: network_dto.NetworkDto) =
  self.view.setData(collection, collectible, network)
