import strutils
import controller_interface
import io_interface

import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/provider/service as provider_service
export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    settingsService: settings_service.Service
    providerService: provider_service.Service

proc newController*(delegate: io_interface.AccessInterface,
    settingsService: settings_service.Service,
    providerService: provider_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.settingsService = settingsService
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

method getCurrentNetwork*(self: Controller): string =
  return self.settingsService.getCurrentNetwork()

method postMessage*(self: Controller, requestType: string, message: string): string =
  return self.providerService.postMessage(requestType, message)

method ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)
