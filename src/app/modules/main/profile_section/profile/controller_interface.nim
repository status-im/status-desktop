import ../../../../../app_service/service/profile/dto/profile as profile_dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeIdentityImage*(self: AccessInterface, address: string, image: string, aX: int, aY: int, bX: int, bY: int):
  seq[Image] {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteIdentityImage*(self: AccessInterface, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")
