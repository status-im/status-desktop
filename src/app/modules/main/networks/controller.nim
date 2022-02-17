import ./controller_interface
import ../../../core/eventemitter
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ./io_interface

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  networkService: network_service.Service,
  walletAccountService: wallet_account_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.networkService = networkService
  result.walletAccountService = walletAccountService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.delegate.refreshNetworks()

method getNetworks*(self: Controller): seq[NetworkDto] =
  return self.networkService.getNetworks()

method toggleNetwork*(self: Controller, chainId: int) =
  self.walletAccountService.toggleNetworkEnabled(chainId)