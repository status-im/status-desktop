method onActiveMailserverChanged*(self: AccessInterface, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")