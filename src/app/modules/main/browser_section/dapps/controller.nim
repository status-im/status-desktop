import Tables
import result
import controller_interface
import io_interface
import options
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
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

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getDapps*(self: Controller): seq[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapps()

method getDapp*(self: Controller, dapp:string, address: string): Option[dapp_permissions_service.Dapp] =
  return self.dappPermissionsService.getDapp(dapp, address)

method hasPermission*(self: Controller, dapp: string, address: string, permission: dapp_permissions_service.Permission):bool =
  return self.dappPermissionsService.hasPermission(dapp, address, permission)

method addPermission*(self: Controller, dapp: string, address: string, permission: dapp_permissions_service.Permission) =
  discard self.dappPermissionsService.addPermission(dapp, address, permission)

method disconnectAddress*(self: Controller, dappName: string, address: string) =
  discard self.dappPermissionsService.disconnectAddress(dappName, address)

method disconnect*(self: Controller, dappName: string) =
  discard self.dappPermissionsService.disconnect(dappName)

method removePermission*(self: Controller, dappName: string, address: string, permission: dapp_permissions_service.Permission) =
  discard self.dappPermissionsService.removePermission(dappName, address, permission)

method getAccountForAddress*(self: Controller, address: string): WalletAccountDto = 
  return self.walletAccountService.getAccountByAddress(address)