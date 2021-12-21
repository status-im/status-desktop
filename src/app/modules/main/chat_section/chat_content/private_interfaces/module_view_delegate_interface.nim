import NimQml

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