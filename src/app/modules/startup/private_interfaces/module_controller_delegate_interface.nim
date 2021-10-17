method userLoggedIn*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitLogOut*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
