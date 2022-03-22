import ./controller_interface
import io_interface
import ../../../../../../app_service/service/collectible/service as collectible_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  collectibleService: collectible_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.collectibleService = collectibleService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getCollections*(self: Controller, address: string): seq[collectible_service.CollectionDto] =
  return self.collectibleService.getCollections(address)
