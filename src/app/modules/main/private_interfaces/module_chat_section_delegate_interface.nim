method chatSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveChatChange*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")