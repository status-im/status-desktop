import ./controller_interface
import ../../../../../../app_service/service/collectible/service as collectible_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    collectibleService: collectible_service.ServiceInterface

proc newController*[T](
  delegate: T, 
  collectibleService: collectible_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.collectibleService = collectibleService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method fetch*[T](self: Controller[T], address: string, collectionSlug: string): seq[collectible_service.CollectibleDto] =
  return self.collectible_service.getCollectibles(address, collectionSlug)