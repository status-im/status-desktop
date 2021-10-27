import controller_interface
import io_interface

import ../../../../../app_service/service/community/service as community_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    id: string
    isCommunityModule: bool
    communityService: community_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, id: string, isCommunity: bool, 
  communityService: community_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.id = id
  result.isCommunityModule = isCommunity
  result.communityService = communityService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getId*(self: Controller): string =
  return self.id

method isCommunity*(self: Controller): bool =
  return self.isCommunityModule