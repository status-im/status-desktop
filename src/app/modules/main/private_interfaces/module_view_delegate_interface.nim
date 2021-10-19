import ../item

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method storePassword*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSection*(self: AccessInterface, item: Item) {.base.} =
  raise newException(ValueError, "No implementation available")

method setUserStatus*(self: AccessInterface, status: bool) {.base.} =
  raise newException(ValueError, "No implementation available")