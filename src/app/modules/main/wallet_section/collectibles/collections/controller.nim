import io_interface
import ../../../../../../app_service/service/collectible/service as collectible_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  collectibleService: collectible_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.collectibleService = collectibleService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getCollections*(self: Controller, address: string): seq[collectible_service.CollectionDto] =
  return self.collectibleService.getCollections(address)
