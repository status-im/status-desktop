method updateOrAddDevice*(self: AccessInterface, installationId: string, name: string, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")