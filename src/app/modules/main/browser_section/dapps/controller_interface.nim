import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

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

method getDapp*(self: AccessInterface, dapp: string, address: string): Option[dapp_permissions_service.Dapp] {.base.} =
  raise newException(ValueError, "No implementation available")

method addPermission*(self: AccessInterface, dapp: string, address: string, permission: dapp_permissions_service.Permission) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasPermission*(self: AccessInterface, dapp: string, address: string, permission: dapp_permissions_service.Permission):bool {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnectAddress*(self: AccessInterface, dapp: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method disconnect*(self: AccessInterface, dapp: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removePermission*(self: AccessInterface, dapp: string, address: string, permission: dapp_permissions_service.Permission) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAccountForAddress*(self: AccessInterface, address: string): WalletAccountDto {.base.} = 
  raise newException(ValueError, "No implementation available")
