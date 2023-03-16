import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method updateOrAddDevice*(self: AccessInterface, installationId: string, name: string, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

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
