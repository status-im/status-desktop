method appSearchDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
