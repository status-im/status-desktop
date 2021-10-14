method accountCreated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setupAccountError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
