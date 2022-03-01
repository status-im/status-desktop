import dto

export dto

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSavedAddresses*(self: ServiceInterface): seq[SavedAddressDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method createOrUpdateSavedAddress*(self: ServiceInterface, name: string, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteSavedAddress*(self: ServiceInterface, address: string): string {.base.} =
  raise newException(ValueError, "No implementation available")
