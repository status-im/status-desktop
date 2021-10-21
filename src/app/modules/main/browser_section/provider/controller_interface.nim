import ../../../../../app_service/service/settings/service as settings_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDappsAddress*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setDappsAddress*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: AccessInterface): NetworkDetails {.base.} =
  raise newException(ValueError, "No implementation available")
