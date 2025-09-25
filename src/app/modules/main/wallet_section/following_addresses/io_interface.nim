type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadFollowingAddresses*(self: AccessInterface, userAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchFollowingAddresses*(self: AccessInterface, userAddress: string, search: string = "", limit: int = 10, offset: int = 0) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTotalFollowingCount*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
