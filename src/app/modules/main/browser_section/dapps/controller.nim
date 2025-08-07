import io_interface
import options
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    dappPermissionsService: dapp_permissions_service.Service
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  dappPermissionsService: dapp_permissions_service.Service,
  walletAccountService: wallet_account_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.dappPermissionsService = dappPermissionsService
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getDapps*(self: Controller): seq[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapps()

proc getDapp*(self: Controller, dapp:string, address: string): Option[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapp(dapp, address)

proc hasPermission*(self: Controller, dapp: string, address: string, permission: dapp_permissions_service.Permission):bool =
  return self.dappPermissionsService.hasPermission(dapp, address, permission)

proc addPermission*(self: Controller, dapp: string, address: string, permission: dapp_permissions_service.Permission) =
  discard self.dappPermissionsService.addPermission(dapp, address, permission)

proc disconnectAddress*(self: Controller, dappName: string, address: string) =
  discard self.dappPermissionsService.disconnectAddress(dappName, address)

proc disconnect*(self: Controller, dappName: string) =
  discard self.dappPermissionsService.disconnect(dappName)

proc removePermission*(self: Controller, dappName: string, address: string, permission: dapp_permissions_service.Permission) =
  discard self.dappPermissionsService.removePermission(dappName, address, permission)

proc getAccountForAddress*(self: Controller, address: string): WalletAccountDto = 
  return self.walletAccountService.getAccountByAddress(address)