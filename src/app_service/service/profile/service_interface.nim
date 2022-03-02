import ./dto/profile as profile_dto

export profile_dto

type
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeIdentityImage*(self: ServiceInterface, address: string, image: string, aX: int, aY: int, bX: int, bY: int):
  seq[Image] {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteIdentityImage*(self: ServiceInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: ServiceInterface, displayName: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")
