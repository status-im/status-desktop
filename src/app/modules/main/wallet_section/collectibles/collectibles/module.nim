import sequtils, sugar, NimQml

import ../../../../../core/global_singleton
import ./io_interface, ./view, ./controller, ./item
import ../../../../../../app_service/service/collectible/service as collectible_service

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool
    currentAddress: string

proc newModule*[T](delegate: T, collectibleService: collectible_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, collectibleService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty(
    "walletSectionCollectiblesCollectibles", newQVariant(self.view)
  )
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method setCurrentAddress*[T](self: Module[T], address: string) = 
  self.currentAddress = address

method fetch*[T](self: Module[T], collectionSlug: string) =
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
