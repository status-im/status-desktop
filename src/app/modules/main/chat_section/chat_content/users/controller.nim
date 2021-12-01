import controller_interface
import io_interface

import ../../../../../../app_service/service/community/service_interface as community_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    chatId: string
    belongsToCommunity: bool
    communityService: community_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, chatId: string, belongsToCommunity: bool, 
  communityService: community_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.communityService = communityService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getChatId*(self: Controller): string =
  return self.chatId

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity