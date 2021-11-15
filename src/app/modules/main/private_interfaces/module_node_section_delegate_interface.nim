method nodeSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
