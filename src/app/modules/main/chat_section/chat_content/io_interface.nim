import NimQml

import ../../../../../app_service/service/message/dto/pinned_message
import ../../../../../app_service/service/chat/dto/chat

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

method onNotificationsUpdated*(self: AccessInterface, hasUnreadMessages: bool, notificationCount: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method newPinnedMessagesLoaded*(self: AccessInterface, pinnedMessages: seq[PinnedMessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUnpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPinMessage*(self: AccessInterface, mmessageId: string, actionInitiatedBy: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReactionAdded*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onReactionRemoved*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleReactionFromOthers*(self: AccessInterface, messageId: string, emojiId: int, reactionId: string,
  reactionFrom: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onContactDetailsUpdated*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatEdited*(self: AccessInterface, chatDto: ChatDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatRenamed*(self: AccessInterface, newName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method inputAreaDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method messagesDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method usersDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getInputAreaModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getUsersModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method unpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyChatId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method isMyContact*(self: AccessInterface, contactId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method muteChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method unmuteChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllMessagesRead*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearChatHistory*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentFleet*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method amIChatAdmin*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method downloadMessages*(self: AccessInterface, filePath: string) =
  raise newException(ValueError, "No implementation available")

method onMutualContactChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
