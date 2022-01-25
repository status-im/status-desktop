method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadMoreMessages*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
  
method toggleReaction*(self: AccessInterface, messageId: string, emojiId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method pinUnpinMessage*(self: AccessInterface, messageId: string, pin: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatType*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatColor*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method amIChatAdmin*(self: AccessInterface): bool {.base.} =
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