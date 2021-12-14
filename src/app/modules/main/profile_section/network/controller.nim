import ./controller_interface
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/network/service as network_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    settingsService: settings_service.ServiceInterface
    networkService: network_service.ServiceInterface

proc newController*[T](delegate: T,
  settingsService: settings_service.ServiceInterface,
  networkService: network_service.ServiceInterface
  ): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.settingsService = settingsService
  result.networkService = networkService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getCurrentNetworkDetails*[T](self: Controller[T]): NetworkDetails =
  self.settingsService.getCurrentNetworkDetails()

method getNetworks*[T](self: Controller[T]): seq[NetworkDetails] =
  self.settingsService.getNetworks()

method changeNetwork*[T](self: Controller[T], network: string) =
  self.settingsService.changeNetwork(network)

method addCustomNetwork*[T](self: Controller[T], name: string, endpoint: string, networkId: int, networkType: string) =
  self.settingsService.addNetwork(name, endpoint, networkId, networkType)