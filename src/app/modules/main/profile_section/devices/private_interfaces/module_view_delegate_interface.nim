method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method isDeviceSetup*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setDeviceName*(self: AccessInterface, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncAllDevices*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method advertise*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableDevice*(self: AccessInterface, installationId: string, enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")