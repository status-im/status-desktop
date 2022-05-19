import io_interface
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/network/service as network_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
 
proc newController*(
  delegate: io_interface.AccessInterface,
  settingsService: settings_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.settingsService = settingsService
  result.walletAccountService = walletAccountService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

proc getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

proc isMnemonicBackedUp*(self: Controller): bool =
  return self.settingsService.getMnemonic().len > 0

proc getCurrencyBalance*(self: Controller): float64 =
  return self.walletAccountService.getCurrencyBalance()

proc updateCurrency*(self: Controller, currency: string) =
  self.walletAccountService.updateCurrency(currency)

proc getIndex*(self: Controller, address: string): int =
  return self.walletAccountService.getIndex(address)