import NimQml

import ../../../../../../app_service/service/message/dto/[message, reaction, pinned_message]
import ../../../../../../app_service/service/community/dto/community
import ../../../../shared_models/message_item
import ../../../../../../app_service/common/types

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

method updateChatFetchMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method newMessagesLoaded*(self: AccessInterface, messages: seq[MessageDto], reactions: seq[ReactionDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method newPinnedMessagesLoaded*(self: AccessInterface, pinnedMessages: seq[PinnedMessageDto]) {.base.} =
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

method messagesAdded*(self: AccessInterface, messages: seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSendingMessageSuccess*(self: AccessInterface, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSendingMessageError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onEnvelopeSent*(self: AccessInterface, messagesIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onEnvelopeExpired*(self: AccessInterface, messagesIds: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMessageDelivered*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateContactDetails*(self: AccessInterface, contactId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMessageEdited*(self: AccessInterface, message: MessageDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method scrollToMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMemberUpdated*(self: AccessInterface, id: string, memberRole: MemberRole, joined: bool) {.base.} =
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

method getChatIcon*(self: AccessInterface): string {.base.} =
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

method editMessage*(self: AccessInterface, messageId: string, contentType: int, updatedMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onHistoryCleared*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewData*(self: AccessInterface, link: string, uuid: string, whiteListedSites: string, whiteListedImgExtensions: string, unfurlImages: bool): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onPreviewDataLoaded*(self: AccessInterface, previewData: string, uuid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method fillGaps*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method didIJoinedChat*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessages*(self: AccessInterface): seq[message_item.Item] {.base.} =
  raise newException(ValueError, "No implementation available")

method onMailserverSynced*(self: AccessInterface, syncedFrom: int64) {.base.} =
  raise newException(ValueError, "No implementation available")

method resendChatMessage*(self: AccessInterface, messageId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method resetNewMessagesMarker*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeNewMessagesMarker*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method resetAndScrollToNewMessagesMarker*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markAllMessagesRead*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method markMessagesAsRead*(self: AccessInterface, messages: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateCommunityDetails*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onFirstUnseenMessageLoaded*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isFirstUnseenMessageInitialized*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method reevaluateViewLoadingState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
