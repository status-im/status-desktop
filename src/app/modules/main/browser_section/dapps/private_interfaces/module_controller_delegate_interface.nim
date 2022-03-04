method hasPermission*(self: AccessInterface, hostname: string, address: string, permission: string): bool =
  raise newException(ValueError, "No implementation available")

method disconnectAddress*(self: AccessInterface, dapp: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removePermission*(self: AccessInterface, dapp: string, address: string, permission: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface, dapp: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchDapps*(self: AccessInterface) =
  raise newException(ValueError, "No implementation available")

method fetchPermissions*(self: AccessInterface, dapp: string, address: string) =
  raise newException(ValueError, "No implementation available")
