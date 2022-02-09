method onChatMuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatUnmuted*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatLeft*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")
