method hasPermission*(self: AccessInterface, hostname: string, permission: string): bool =
  raise newException(ValueError, "No implementation available")

method addPermission*(self: AccessInterface, hostname: string, permission: string) =
  raise newException(ValueError, "No implementation available")

method clearPermissions*(self: AccessInterface, dapp: string) =
  raise newException(ValueError, "No implementation available")

method revokePermission*(self: AccessInterface, dapp: string, name: string) =
  raise newException(ValueError, "No implementation available")

method revokeAllPermissions*(self: AccessInterface) =
  raise newException(ValueError, "No implementation available")

method fetchDapps*(self: AccessInterface) =
  raise newException(ValueError, "No implementation available")

method fetchPermissions*(self: AccessInterface, dapp: string) =
  raise newException(ValueError, "No implementation available")
