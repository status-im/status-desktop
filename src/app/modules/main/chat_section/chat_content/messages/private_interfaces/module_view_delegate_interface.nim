method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleReaction*(self: AccessInterface, messageId: string, emojiId: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method pinUnpinMessage*(self: AccessInterface, messageId: string, pin: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNamesReactedWithEmojiIdForMessageId*(self: AccessInterface, messageId: string, emojiId: int): seq[string] 
  {.base.} =
  raise newException(ValueError, "No implementation available")