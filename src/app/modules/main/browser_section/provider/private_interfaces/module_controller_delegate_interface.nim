method setDappsAddress*(self: AccessInterface, newDappAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDappAddressChanged*(self: AccessInterface, newDappAddress: string) {.base.}  =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method postMessage*(self: AccessInterface, requestType: string, message: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: AccessInterface, hostname: string, permission: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method ensResourceURL*(self: AccessInterface, ens: string, url: string): (string, string, string, string, bool) =
  raise newException(ValueError, "No implementation available")
