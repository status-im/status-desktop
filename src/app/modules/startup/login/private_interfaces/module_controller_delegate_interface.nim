method emitAccountLoginError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordError*(self: AccessInterface, errorDescription: string) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordSuccess*(self: AccessInterface, password: string) 
  {.base.} =
  raise newException(ValueError, "No implementation available")