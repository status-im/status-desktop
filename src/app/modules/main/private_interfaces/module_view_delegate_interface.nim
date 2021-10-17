method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")