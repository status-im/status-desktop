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
    id: string
    isCommunityModule: bool
    activeItemId: string
    activeSubItemId: string
    chatService: chat_service.ServiceInterface
    communityService: community_service.ServiceInterface
    messageService: message_service.Service

proc newController*(delegate: io_interface.AccessInterface, id: string, isCommunity: bool, 
  chatService: chat_service.ServiceInterface,
  communityService: community_service.ServiceInterface,
  messageService: message_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.id = id
  result.isCommunityModule = isCommunity
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getId*(self: Controller): string =
  return self.id

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

  if(self.activeSubItemId.len > 0):
    self.messageService.loadInitialMessagesForChat(self.activeSubItemId)
  else:
    self.messageService.loadInitialMessagesForChat(self.activeItemId)

  # We need to take other actions here like notify status go that unviewed mentions count is updated and so...

  self.delegate.activeItemSubItemSet(self.activeItemId, self.activeSubItemId)