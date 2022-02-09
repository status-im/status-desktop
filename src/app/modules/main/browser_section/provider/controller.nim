import strutils
import controller_interface
import io_interface

import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../../app_service/service/provider/service_interface as provider_service
export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    settingsService: settings_service.ServiceInterface
    dappPermissionsService: dapp_permissions_service.ServiceInterface
    providerService: provider_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
    settingsService: settings_service.ServiceInterface,
    dappPermissionsService: dapp_permissions_service.ServiceInterface,
    providerService: provider_service.ServiceInterface):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.settingsService = settingsService
  result.dappPermissionsService = dappPermissionsService
  result.providerService = providerService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

method setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.saveDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

method getCurrentNetworkId*(self: Controller): int =
  return self.settingsService.getCurrentNetworkId()

method disconnect*(self: Controller) =
  discard self.dappPermissionsService.revoke("web3".toPermission())

method postMessage*(self: Controller, requestType: string, message: string): string =
  return self.providerService.postMessage(requestType, message)

method hasPermission*(self: Controller, hostname: string, permission: string): bool =
  return self.dappPermissionsService.hasPermission(hostname, permission.toPermission())

method ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)
