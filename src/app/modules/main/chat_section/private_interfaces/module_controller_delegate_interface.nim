method activeItemSubItemSet*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewChat*(self: AccessInterface, chatDto: ChatDto, events: EventEmitter, 
  contactService: contact_service.Service, chatService: chat_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMarkAllMessagesRead*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")