# import ../../../../../app_service/service/profile/service as profile_service

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewWhitelist*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method changePassword*(self: AccessInterface, password: string, newPassword: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
