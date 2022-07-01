import ../../../core/eventemitter
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/settings/service as settings_service
import ./io_interface


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service
    settingsService: settings_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  networkService: network_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.networkService = networkService
  result.walletAccountService = walletAccountService
  result.settingsService = settingsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.delegate.refreshNetworks()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.delegate.refreshNetworks()

proc getNetworks*(self: Controller): seq[NetworkDto] =
  return self.networkService.getNetworks()

proc toggleNetwork*(self: Controller, chainId: int) =
  self.walletAccountService.toggleNetworkEnabled(chainId)

proc areTestNetworksEnabled*(self: Controller): bool =
  return self.settingsService.areTestNetworksEnabled()

proc toggleTestNetworksEnabled*(self: Controller) =
  self.walletAccountService.toggleTestNetworksEnabled()

proc getNetworkCurrencyBalance*(self: Controller, network: NetworkDto): float64 = 
  return self.walletAccountService.getNetworkCurrencyBalance(network)