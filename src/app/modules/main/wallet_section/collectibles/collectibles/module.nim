import sequtils, sugar, NimQml

import ../../../../../global/global_singleton
import ./io_interface, ./view, ./controller, ./item
import ../io_interface as delegate_interface
import ../../../../../../app_service/service/collectible/service as collectible_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool
    currentAddress: string

proc newModule*(delegate: delegate_interface.AccessInterface, collectibleService: collectible_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController(result, collectibleService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionCollectiblesCollectibles", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.collectiblesModuleDidLoad()

method setCurrentAddress*(self: Module, address: string) =
  self.currentAddress = address

method fetch*(self: Module, collectionSlug: string) =
  let collectibles = self.controller.fetch(self.currentAddress, collectionSlug)
  let items = collectibles.map(c => initItem(
    c.id,
    c.name,
    c.imageUrl,
    c.backgroundColor,
    c.description,
    c.permalink,
    c.properties.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.rankings.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.statistics.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
  ))
  self.view.setItems(collectionSlug, items)

method getCollectible*(self: Module, collectionSlug: string, id: int): Item =
  return self.view.getCollectible(collectionSlug, id)
