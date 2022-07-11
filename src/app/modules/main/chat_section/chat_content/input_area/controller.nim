import io_interface

import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/gif/service as gif_service
import ../../../../../../app_service/service/gif/dto

type
  Controller* = ref object of RootObj
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

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getChatId*(self: Controller): string =
  return self.chatId

proc belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

proc sendImages*(self: Controller, imagePathsJson: string): string =
  self.chatService.sendImages(self.chatId, imagePathsJson)

proc sendImagesWithOneMessage*(self: Controller, imagePathsJson: string, msg: string): string =
  self.chatService.sendImagesWithOneMessage(self.chatId, imagePathsJson, msg)

proc sendChatMessage*(
    self: Controller,
    msg: string,
    replyTo: string,
    contentType: int,
    preferredUsername: string = "") =

  self.chatService.sendChatMessage(self.chatId, msg, replyTo, contentType, preferredUsername)

proc requestAddressForTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestAddressForTransaction(self.chatId, fromAddress, amount, tokenAddress)

proc requestTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestTransaction(self.chatId, fromAddress, amount, tokenAddress)

proc declineRequestTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestTransaction(messageId)

proc declineRequestAddressForTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestAddressForTransaction(messageId)

proc acceptRequestAddressForTransaction*(self: Controller, messageId: string, address: string) =
  self.chatService.acceptRequestAddressForTransaction(messageId, address)

proc acceptRequestTransaction*(self: Controller, transactionHash: string, messageId: string, signature: string) =
  self.chatService.acceptRequestTransaction(transactionHash, messageId, signature)

proc searchGifs*(self: Controller, query: string): seq[GifDto] =
  return self.gifService.search(query)

proc getTrendingsGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getTrendings()

proc getRecentsGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getRecents()

proc getFavoritesGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getFavorites()

proc toggleFavoriteGif*(self: Controller, item: GifDto) =
  self.gifService.toggleFavorite(item)

proc addToRecentsGif*(self: Controller, item: GifDto) =
  self.gifService.addToRecents(item)

proc isFavorite*(self: Controller, item: GifDto): bool =
  return self.gifService.isFavorite(item)
