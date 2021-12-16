import Tables, stint
import eventemitter
import ./controller_interface
import ./io_interface

import ../../../../app/core/signals/types
import ../../../../app_service/service/community/service as community_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    communityService: community_service.Service

proc newController*[T](
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service
    ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.communityService = communityService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  let communities = self.communityService.getAllCommunities()
  self.delegate.setAllCommunities(communities)

method joinCommunity*[T](self: Controller[T], communityId: string): string =
  self.communityService.joinCommunity(communityId)

