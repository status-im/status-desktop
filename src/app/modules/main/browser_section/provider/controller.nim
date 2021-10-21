import Tables
import result
import controller_interface
import io_interface

import ../../../../../app_service/service/settings/service as settings_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    settingsService: settings_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, 
  settingsService: settings_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.settingsService = settingsService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

method setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.setDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

method getCurrentNetworkDetails*(self: Controller): NetworkDetails =
  return self.settingsService.getCurrentNetworkDetails()