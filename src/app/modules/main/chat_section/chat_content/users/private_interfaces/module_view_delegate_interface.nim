method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMembersPublicKeys*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")
