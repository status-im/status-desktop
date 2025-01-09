import io_interface
import app/core/eventemitter
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/saved_address/service as saved_address_service

type Controller* = ref object of RootObj
  delegate: io_interface.AccessInterface
  events: EventEmitter
  savedAddressService: saved_address_service.Service

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    savedAddressService: saved_address_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.savedAddressService = savedAddressService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.delegate.loadSavedAddresses()

  self.events.on(SIGNAL_SAVED_ADDRESSES_UPDATED) do(e: Args):
    self.delegate.loadSavedAddresses()

  self.events.on(SIGNAL_SAVED_ADDRESS_UPDATED) do(e: Args):
    let args = SavedAddressArgs(e)
    self.delegate.savedAddressUpdated(
      args.name, args.address, args.isTestAddress, args.errorMsg
    )

  self.events.on(SIGNAL_SAVED_ADDRESS_DELETED) do(e: Args):
    let args = SavedAddressArgs(e)
    self.delegate.savedAddressDeleted(args.address, args.isTestAddress, args.errorMsg)

proc areTestNetworksEnabled*(self: Controller): bool =
  return self.savedAddressService.areTestNetworksEnabled()

proc getSavedAddresses*(self: Controller): seq[saved_address_service.SavedAddressDto] =
  return self.savedAddressService.getSavedAddresses()

proc getSavedAddress*(
    self: Controller, address: string, ignoreNetworkMode: bool
): SavedAddressDto =
  return self.savedAddressService.getSavedAddress(address, ignoreNetworkMode)

proc createOrUpdateSavedAddress*(
    self: Controller, name: string, address: string, ens: string, colorId: string
) =
  self.savedAddressService.createOrUpdateSavedAddress(name, address, ens, colorId)

proc deleteSavedAddress*(self: Controller, address: string) =
  self.savedAddressService.deleteSavedAddress(address)

proc remainingCapacityForSavedAddresses*(self: Controller): int =
  return self.savedAddressService.remainingCapacityForSavedAddresses()
