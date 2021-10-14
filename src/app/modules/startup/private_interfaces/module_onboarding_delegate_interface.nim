method onboardingDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method accountCreated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")