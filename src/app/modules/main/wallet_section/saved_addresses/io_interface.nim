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

method loadSavedAddresses*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method createOrUpdateSavedAddress*(self: AccessInterface, name: string, address: string, favourite: bool): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteSavedAddress*(self: AccessInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
