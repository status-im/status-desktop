method activeItemSubItemSet*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewPublicChat*(self: AccessInterface, chatDto: ChatDto, events: EventEmitter, 
  chatService: chat_service.ServiceInterface, communityService: community_service.ServiceInterface, 
  messageService: message_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")