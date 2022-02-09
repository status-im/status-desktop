method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isAutomaticSelection*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMailserverNameForNodeAddress*(self: AccessInterface, nodeAddress: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveMailserver*(self: AccessInterface, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNewMailserver*(self: AccessInterface, name: string, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableAutomaticSelection*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
