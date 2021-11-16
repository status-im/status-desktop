import NimQml, sequtils, sugar

import ../../../../../global/global_singleton
import ./io_interface, ./view, ./controller, ./item
import ../../../../../../app_service/service/collectible/service as collectible_service

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

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
    "walletSectionCollectiblesCollections", newQVariant(self.view)
  )
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method loadCollections*[T](self: Module[T], address: string) =
  let collections = self.controller.getCollections(address)
  self.view.setItems(
    collections.map(c => initItem(
      c.name,
      c.slug,
      c.imageUrl,
      c.ownedAssetCount,
    ))
  )