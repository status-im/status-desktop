import controller_interface
import io_interface

import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/gif/service as gif_service
import ../../../../../../app_service/service/gif/dto

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    sectionId: string
    chatId: string
    belongsToCommunity: bool
    communityService: community_service.Service
    chatService: chat_service.Service
    gifService: gif_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    sectionId: string,
    chatId: string,
    belongsToCommunity: bool,
    chatService: chat_service.Service, 
    communityService: community_service.Service,
    gifService: gif_service.Service
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.sectionId = chatId
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.chatService = chatService
  result.communityService = communityService
  result.gifService = gifService
  
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

method sendChatMessage*(
    self: Controller,
    msg: string,
    replyTo: string,
    contentType: int,
    preferredUsername: string = "") =

  self.chatService.sendChatMessage(self.chatId, msg, replyTo, contentType, preferredUsername)

method requestAddressForTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestAddressForTransaction(self.chatId, fromAddress, amount, tokenAddress)

method requestTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestTransaction(self.chatId, fromAddress, amount, tokenAddress)

method declineRequestTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestTransaction(messageId)

method declineRequestAddressForTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestAddressForTransaction(messageId)

method acceptRequestAddressForTransaction*(self: Controller, messageId: string, address: string) =
  self.chatService.acceptRequestAddressForTransaction(messageId, address)

method acceptRequestTransaction*(self: Controller, transactionHash: string, messageId: string, signature: string) =
  self.chatService.acceptRequestTransaction(transactionHash, messageId, signature)

method searchGifs*(self: Controller, query: string): seq[GifDto] =
  return self.gifService.search(query)

method getTrendingsGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getTrendings()

method getRecentsGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getRecents()

method getFavoritesGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getFavorites()

method toggleFavoriteGif*(self: Controller, item: GifDto) =
  self.gifService.toggleFavorite(item)

method addToRecentsGif*(self: Controller, item: GifDto) =
  self.gifService.addToRecents(item)

method isFavorite*(self: Controller, item: GifDto): bool =
  return self.gifService.isFavorite(item)