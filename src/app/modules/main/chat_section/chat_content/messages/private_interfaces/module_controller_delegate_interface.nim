import ../../../../../../../app_service/service/message/dto/[message, reaction, pinned_message]

method newMessagesLoaded*(self: AccessInterface, messages: seq[MessageDto], reactions: seq[ReactionDto],
  pinnedMessages: seq[PinnedMessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReactionAdded*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReactionRemoved*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleReactionFromOthers*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string,
  reactionFrom: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPinMessage*(self: AccessInterface, messageId: string, actionInitiatedBy: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUnpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method messageAdded*(self: AccessInterface, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSendingMessageSuccess*(self: AccessInterface, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSendingMessageError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateContactDetails*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMessageEdited*(self: AccessInterface, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method scrollToMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMemberUpdated*(self: AccessInterface, id: string, admin: bool, joined: bool) {.base.} =
  raise newException(ValueError, "No implementation available")