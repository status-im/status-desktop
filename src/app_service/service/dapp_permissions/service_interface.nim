import dto/dapp
import dto/permission
import results
import options
export dapp
export permission

type R = Result[Dapp, string]

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDapps*(self: ServiceInterface): seq[Dapp] {.base.} =
  raise newException(ValueError, "No implementation available")

method getDapp*(self: ServiceInterface, dapp: string): Option[Dapp] {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: ServiceInterface, dapp: string, permission: Permission): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method clearPermissions*(self: ServiceInterface, dapp: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method revoke*(self: ServiceInterface, permission: Permission): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method revoke*(self: ServiceInterface, dapp: string, permission: Permission): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method revokeAllPermisions*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method addPermission*(self: ServiceInterface, dapp: string, permission: Permission): R {.base.}  =
  raise newException(ValueError, "No implementation available")

