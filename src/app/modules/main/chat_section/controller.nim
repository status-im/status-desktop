import Tables

import controller_interface
import io_interface

import ../../../../app_service/service/chat/service as chat_service
import ../../../../app_service/service/community/service as community_service
import ../../../../app_service/service/message/service as message_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    sectionId: string
    isCommunityModule: bool
    activeItemId: string
    activeSubItemId: string
    chatService: chat_service.ServiceInterface
    communityService: community_service.ServiceInterface
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, sectionId: string, isCommunity: bool, 
  chatService: chat_service.ServiceInterface,
  communityService: community_service.ServiceInterface,
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.sectionId = sectionId
  result.isCommunityModule = isCommunity
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getMySectionId*(self: Controller): string =
  return self.sectionId

method getActiveChatId*(self: Controller): string =
  if(self.activeSubItemId.len > 0):
    return self.activeSubItemId
  else:
    return self.activeItemId

method isCommunity*(self: Controller): bool =
  return self.isCommunityModule

method getCommunityIds*(self: Controller): seq[string] =
  return self.communityService.getCommunityIds()

method getCategories*(self: Controller, communityId: string): seq[Category] =
  return self.communityService.getCategories(communityId)

method getChats*(self: Controller, communityId: string, categoryId: string): seq[Chat] =
  return self.communityService.getChats(communityId, categoryId)

method getChatDetails*(self: Controller, communityId, chatId: string): ChatDto =
  let fullId = communityId & chatId
  return self.chatService.getChatById(fullId)

method getChatDetailsForChatTypes*(self: Controller, types: seq[ChatType]): seq[ChatDto] =
  return self.chatService.getChatsOfChatTypes(types)

method setActiveItemSubItem*(self: Controller, itemId: string, subItemId: string) =
  self.activeItemId = itemId
  self.activeSubItemId = subItemId

  self.messageService.asyncLoadInitialMessagesForChat(self.getActiveChatId())

  # We need to take other actions here like notify status go that unviewed mentions count is updated and so...

  self.delegate.activeItemSubItemSet(self.activeItemId, self.activeSubItemId)

method getOneToOneChatNameAndImage*(self: Controller, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.chatService.getOneToOneChatNameAndImage(chatId)