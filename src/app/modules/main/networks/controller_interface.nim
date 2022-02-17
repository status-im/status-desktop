import ../../../../app_service/service/network/dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworks*(self: AccessInterface): seq[NetworkDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleNetwork*(self: AccessInterface, chainId: int) {.base.} =
  raise newException(ValueError, "No implementation available")