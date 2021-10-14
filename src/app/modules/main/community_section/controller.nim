import Tables

import controller_interface
import io_interface

import ../../../../app_service/service/community/service as community_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    id: string
    communityService: community_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
  id: string,
  communityService: community_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.id = id
  result.communityService = communityService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getId*(self: Controller): string =
  return self.id

method getCommunities*(self: Controller): seq[community_service.Dto] =
  return self.communityService.getCommunities()