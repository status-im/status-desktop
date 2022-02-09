import Tables
import result
import controller_interface
import io_interface
import options
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    dappPermissionsService: dapp_permissions_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
  dappPermissionsService: dapp_permissions_service.ServiceInterface):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.dappPermissionsService = dappPermissionsService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getDapps*(self: Controller): seq[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapps()

method getDapp*(self: Controller, dapp:string): Option[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapp(dapp)

method hasPermission*(self: Controller, dapp: string, permission: dapp_permissions_service.Permission):bool =
  return self.dappPermissionsService.hasPermission(dapp, permission)

method addPermission*(self: Controller, dapp: string, permission: dapp_permissions_service.Permission) =
  discard self.dappPermissionsService.addPermission(dapp, permission)

method clearPermissions*(self: Controller, dapp: string) =
  discard self.dappPermissionsService.clearPermissions(dapp)

method revokeAllPermisions*(self: Controller) =
  discard self.dappPermissionsService.revokeAllPermisions()

method revokePermission*(self: Controller, dapp: string, permission: string) =
  discard self.dappPermissionsService.revoke(dapp, permission.toPermission())
