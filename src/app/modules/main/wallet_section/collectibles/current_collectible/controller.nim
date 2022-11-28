import io_interface

import ../../../../../../app_service/service/collectible/service as collectible_service
import ../collectibles/module as collectibles_module
import ../collections/module as collections_module

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.Service
    collectiblesModule: collectibles_module.AccessInterface
    collectionsModule: collections_module.AccessInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  collectibleService: collectible_service.Service,
  collectiblesModule: collectibles_module.AccessInterface,
  collectionsModule: collections_module.AccessInterface
): Controller =
  result = Controller()
  result.delegate = delegate
  result.collectibleService = collectibleService
  result.collectiblesModule = collectiblesModule
  result.collectionsModule = collectionsModule

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc update*(self: Controller, slug: string, id: int) =
  self.delegate.setData(self.collectionsModule.getCollection(slug), self.collectiblesModule.getCollectible(slug, id), self.collectibleService.getNetwork())
