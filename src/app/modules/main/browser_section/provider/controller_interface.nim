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

method getCurrentNetworkId*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method postMessage*(self: AccessInterface, message: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: AccessInterface, hostname: string, permission: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method ensResourceURL*(self: AccessInterface, ens: string, url: string): (string, string, string, string, bool) =
  raise newException(ValueError, "No implementation available")
