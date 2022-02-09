import ../../../../../app_service/service/dapp_permissions/service_interface as dapp_permissions_service
import options

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDapps*(self: AccessInterface): seq[dapp_permissions_service.Dapp] {.base.} =
  raise newException(ValueError, "No implementation available")

method getDapp*(self: AccessInterface, dapp: string): Option[dapp_permissions_service.Dapp] {.base.} =
  raise newException(ValueError, "No implementation available")

method addPermission*(self: AccessInterface, dapp: string, permission: dapp_permissions_service.Permission) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: AccessInterface, dapp: string, permission: dapp_permissions_service.Permission):bool {.base.} =
  raise newException(ValueError, "No implementation available")

method clearPermissions*(self: AccessInterface, dapp: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method revokePermission*(self: AccessInterface, dapp: string, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method revokeAllPermisions*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
