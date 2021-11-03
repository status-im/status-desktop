import Tables

import controller_interface
import io_interface

import ../../../../../app_service/service/chat/service as chat_service
import ../../../../../app_service/service/community/service as community_service
import ../../../../../app_service/service/message/service as message_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    chatId: string
    belongsToCommunity: bool
    chatService: chat_service.ServiceInterface
    communityService: community_service.ServiceInterface
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, chatId: string, belongsToCommunity: bool, 
  chatService: chat_service.ServiceInterface,
  communityService: community_service.ServiceInterface,
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getChatId*(self: Controller): string =
  return self.chatId

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity