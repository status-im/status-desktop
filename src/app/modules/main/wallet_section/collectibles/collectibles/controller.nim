import ./controller_interface
import io_interface
import ../../../../../../app_service/service/collectible/service as collectible_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    collectibleService: collectible_service.ServiceInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  collectibleService: collectible_service.ServiceInterface
): Controller =
  result = Controller()
  result.delegate = delegate
  result.collectibleService = collectibleService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method fetch*(self: Controller, address: string, collectionSlug: string): seq[collectible_service.CollectibleDto] =
  return self.collectible_service.getCollectibles(address, collectionSlug)
