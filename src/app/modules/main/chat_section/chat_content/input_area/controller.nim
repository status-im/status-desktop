import controller_interface
import io_interface

import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    chatId: string
    belongsToCommunity: bool
    communityService: community_service.ServiceInterface
    chatService: chat_service.ServiceInterface

proc newController*(
    delegate: io_interface.AccessInterface,
    chatId: string,
    belongsToCommunity: bool,
    chatService: chat_service.ServiceInterface, 
    communityService: community_service.ServiceInterface
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.chatService = chatService
  result.communityService = communityService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getChatId*(self: Controller): string =
  return self.chatId

method belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

method sendImages*(self: Controller, imagePathsJson: string): string =
  self.chatService.sendImages(self.chatId, imagePathsJson)

method requestAddressForTransaction*(self: Controller, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)

method requestTransaction*(self: Controller, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestAddressForTransaction(chatId, fromAddress, amount, tokenAddress)

method declineRequestTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestTransaction(messageId)

method declineRequestAddressForTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestAddressForTransaction(messageId)

method acceptRequestAddressForTransaction*(self: Controller, messageId: string, address: string) =
  self.chatService.acceptRequestAddressForTransaction(messageId, address)

method acceptRequestTransaction*(self: Controller, transactionHash: string, messageId: string, signature: string) =
  self.chatService.acceptRequestTransaction(transactionHash, messageId, signature)