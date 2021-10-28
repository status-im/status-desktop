# import ../../../../../app_service/service/profile/service as profile_service

import status/types/[installation]

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDeviceName*(self: AccessInterface, deviceName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncAllDevices*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method advertiseDevice*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllDevices*(self: AccessInterface): seq[Installation] {.base.} =
  raise newException(ValueError, "No implementation available")

method isDeviceSetup*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method enableInstallation*(self: AccessInterface, installationId: string, enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
