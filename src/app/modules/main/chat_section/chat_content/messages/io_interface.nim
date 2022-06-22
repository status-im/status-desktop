import NimQml

import ../../../../../../app_service/service/message/dto/[message, reaction, pinned_message]
import ../../../../shared_models/message_item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method updateChatIdentifier*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

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

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleReaction*(self: AccessInterface, messageId: string, emojiId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method pinUnpinMessage*(self: AccessInterface, messageId: string, pin: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")
  
method getChatType*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatColor*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method amIChatAdmin*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method pinMessageAllowedForMembers*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getNumberOfPinnedMessages*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMessageDeleted*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method editMessage*(self: AccessInterface, messageId: string, updatedMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onHistoryCleared*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewData*(self: AccessInterface, link: string, uuid: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onPreviewDataLoaded*(self: AccessInterface, previewData: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method fillGaps*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method didIJoinedChat*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessages*(self: AccessInterface): seq[message_item.Item] =
  raise newException(ValueError, "No implementation available")