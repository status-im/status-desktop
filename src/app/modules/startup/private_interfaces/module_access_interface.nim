method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method moveToAppState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method startUpUIRaised*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")