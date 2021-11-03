import controller_interface
import io_interface

import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    chatId: string
    belongsToCommunity: bool
    communityService: community_service.ServiceInterface
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, chatId: string, belongsToCommunity: bool, 
  communityService: community_service.ServiceInterface, messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_MESSAGES_LOADED) do(e:Args):
    let args = MessagesLoadedArgs(e)
    echo "RECEIVED MESSAGES ASYNC: ", repr(args)

method getChatId*(self: Controller): string =
  return self.chatId

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity