import ./controller_interface
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/network/service as network_service
import ./io_interface

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    networkService: network_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  networkService: network_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.networkService = networkService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method getNetworks*(self: Controller): seq[NetworkDto] =
  return self.networkService.getNetworks()