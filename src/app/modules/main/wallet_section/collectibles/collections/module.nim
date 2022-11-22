import NimQml, sequtils, sugar

import ../../../../../global/global_singleton
import ./io_interface, ./view, ./controller, ./item
import ../io_interface as delegate_interface
import ../../../../../../app_service/service/collectible/service as collectible_service
import ../../../../../core/eventemitter

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, collectibleService: collectible_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController(result, events, collectibleService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCollectiblesCollections", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.collectionsModuleDidLoad()

method loadCollections*(self: Module, address: string) =
  self.controller.getCollections(address)

method setCollections*(self: Module, collections: seq[CollectionDto]) =
  self.view.setItems(
    collections.map(c => initItem(
      c.name,
      c.slug,
      c.imageUrl,
      c.ownedAssetCount,
    ))
  )

method getCollection*(self: Module, slug: string): Item = 
  return self.view.getCollection(slug)
