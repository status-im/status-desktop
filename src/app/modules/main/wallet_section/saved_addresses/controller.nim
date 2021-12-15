import eventemitter
import ./controller_interface
import io_interface
import ../../../../../app_service/service/saved_address/service as saved_address_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    savedAddressService: saved_address_service.ServiceInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  savedAddressService: saved_address_service.ServiceInterface
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.savedAddressService = savedAddressService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_SAVED_ADDRESS_CHANGED) do(e:Args):
    self.delegate.loadSavedAddresses()

method getSavedAddresses*(self: Controller): seq[saved_address_service.SavedAddressDto] =
  return self.savedAddressService.getSavedAddresses()

method createOrUpdateSavedAddress*(self: Controller, name, address: string) =
  self.savedAddressService.createOrUpdateSavedAddress(name, address)

method deleteSavedAddress*(self: Controller, address: string) =
  self.savedAddressService.deleteSavedAddress(address)
