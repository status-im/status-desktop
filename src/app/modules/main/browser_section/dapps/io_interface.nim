type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method onActivated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadDapps*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: AccessInterface, hostname: string, address: string, permission: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnectAddress*(self: AccessInterface, dapp: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removePermission*(self: AccessInterface, dapp: string, address: string, permission: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface, dapp: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchDapps*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchPermissions*(self: AccessInterface, dapp: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method addPermission*(self: AccessInterface, hostname: string, address: string, permission: string) {.base.} =
  raise newException(ValueError, "No implementation available")