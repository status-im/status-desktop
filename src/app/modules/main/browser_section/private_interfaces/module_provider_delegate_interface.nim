method providerDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
