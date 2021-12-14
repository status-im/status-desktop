import ./controller_interface
import io_interface
import ../../../../../app_service/service/saved_address/service as saved_address_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    savedAddressService: saved_address_service.ServiceInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  savedAddressService: saved_address_service.ServiceInterface
): Controller =
  result = Controller()
  result.delegate = delegate
  result.savedAddressService = savedAddressService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getSavedAddresses*(self: Controller): seq[saved_address_service.SavedAddressDto] =
  return self.savedAddressService.getSavedAddresses()

method addSavedAddress*(self: Controller, name, address: string) =
  self.savedAddressService.addSavedAddress(name, address)

method deleteSavedAddress*(self: Controller, address: string) =
  self.savedAddressService.deleteSavedAddress(address)
