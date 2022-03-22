import strutils
import io_interface

import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/provider/service as provider_service

type
  Controller* = ref object of RootObj
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

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

proc setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.saveDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

proc getCurrentNetworkId*(self: Controller): int =
  return self.settingsService.getCurrentNetworkId()

proc getCurrentNetwork*(self: Controller): string =
  return self.settingsService.getCurrentNetwork()

proc postMessage*(self: Controller, requestType: string, message: string): string =
  return self.providerService.postMessage(requestType, message)

proc ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)
