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

method createOrUpdateSavedAddress*(self: AccessInterface, name: string, address: string, ens: string, colorId: string,
  chainShortNames: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method updatePreferredChains*(self: AccessInterface, address: string, chainShortNames: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteSavedAddress*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method savedAddressUpdated*(self: AccessInterface, name: string, address: string, errorMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method savedAddressDeleted*(self: AccessInterface, address: string, errorMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method savedAddressNameExists*(self: AccessInterface, name: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSavedAddressAsJson*(self: AccessInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this
  ## module.
  DelegateInterface* = concept c
