import controller_interface
import io_interface

import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    id: string
    isCommunityModule: bool
    communityService: community_service.ServiceInterface
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, id: string, isCommunity: bool, 
  communityService: community_service.ServiceInterface, messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.id = id
  result.isCommunityModule = isCommunity
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    echo "RECEIVED MESSAGES ASYNC: ", repr(args)

method getId*(self: Controller): string =
  return self.id

method isCommunity*(self: Controller): bool =
  return self.isCommunityModule
