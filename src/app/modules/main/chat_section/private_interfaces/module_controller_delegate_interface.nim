method activeItemSubItemSet*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewChat*(self: AccessInterface, chatDto: ChatDto, belongsToCommunity: bool, events: EventEmitter,
  settingsService: settings_service.ServiceInterface, contactService: contact_service.Service, 
  chatService: chat_service.Service, communityService: community_service.Service, 
  messageService: message_service.Service, gifService: gif_service.Service) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewMessagesReceived*(self: AccessInterface, chatId: string, unviewedMessagesCount: int, 
  unviewedMentionsCount: int, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMarkAllMessagesRead*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactAccepted*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactRejected*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactBlocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactDetailsUpdated*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityChannelDeleted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")
  
method onChatRenamed*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")
