import io_interface
import ../../../../core/eventemitter
import ../../../../../app_service/service/saved_address/service as saved_address_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    savedAddressService: saved_address_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  savedAddressService: saved_address_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.savedAddressService = savedAddressService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SAVED_ADDRESS_CHANGED) do(e:Args):
    self.delegate.loadSavedAddresses()

proc getSavedAddresses*(self: Controller): seq[saved_address_service.SavedAddressDto] =
  return self.savedAddressService.getSavedAddresses()

proc createOrUpdateSavedAddress*(self: Controller, name: string, address: string, favourite: bool): string =
  return self.savedAddressService.createOrUpdateSavedAddress(name, address, favourite)

proc deleteSavedAddress*(self: Controller, address: string): string =
  return self.savedAddressService.deleteSavedAddress(address)
