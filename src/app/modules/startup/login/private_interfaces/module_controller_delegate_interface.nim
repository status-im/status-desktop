method loginAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitStoreToKeychainValueChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")