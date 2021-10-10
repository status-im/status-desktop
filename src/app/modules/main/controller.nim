import Tables

import controller_interface

import ../../../app_service/service/community/service as community_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T
    communityService: community_service.ServiceInterface

proc newController*[T](delegate: T, 
  communityService: community_service.ServiceInterface): 
  Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.communityService = communityService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard