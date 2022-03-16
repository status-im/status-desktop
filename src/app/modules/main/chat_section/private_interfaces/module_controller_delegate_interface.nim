method activeItemSubItemSet*(self: AccessInterface, itemId: string, subItemId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method makeChatWithIdActive*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method addNewChat*(self: AccessInterface, chatDto: ChatDto, belongsToCommunity: bool, events: EventEmitter,
  settingsService: settings_service.ServiceInterface, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  visualIdentityService: visual_identity_service.Service, setChatAsActive: bool = true) {.base.} =
  raise newException(ValueError, "No implementation available")

method doesCatOrChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method doesTopLevelChatExist*(self: AccessInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method addChatIfDontExist*(self: AccessInterface,
    chat: ChatDto,
    belongsToCommunity: bool,
    events: EventEmitter,
    settingsService: settings_service.ServiceInterface,
    contactService: contact_service.Service,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    messageService: message_service.Service,
    gifService: gif_service.Service,
    mailserversService: mailservers_service.Service,
    visualIdentityService: visual_identity_service.Service,
    setChatAsActive: bool = true) {.base.} =
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

method onContactUnblocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactDetailsUpdated*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityChannelDeletedOrChatLeft*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatRenamed*(self: AccessInterface, chatId: string, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityChannelEdited*(self: AccessInterface, chat: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReorderChatOrCategory*(self: AccessInterface, chatOrCatId: string, position: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryCreated*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryDeleted*(self: AccessInterface, category: Category) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityCategoryEdited*(self: AccessInterface, category: Category, chats: seq[ChatDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCategoryNameChanged*(self: AccessInterface, category: Category) {.base.} =
  raise newException(ValueError, "No implementation available")

method setLoadingHistoryMessagesInProgress*(self: AccessInterface, isLoading: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
