method loginAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")