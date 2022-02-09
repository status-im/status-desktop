import ../../../../../app_service/service/devices/dto/device

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyInstallationId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllDevices*(self: AccessInterface): seq[DeviceDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method isDeviceSetup*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setDeviceName*(self: AccessInterface, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncAllDevices*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method advertise*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableDevice*(self: AccessInterface, deviceId: string, enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
