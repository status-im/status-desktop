import ../../../../../../app_service/service/message/dto/pinned_message

method newPinnedMessagesLoaded*(self: AccessInterface, pinnedMessages: seq[PinnedMessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUnpinMessage*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPinMessage*(self: AccessInterface, mmessageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatMuted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
