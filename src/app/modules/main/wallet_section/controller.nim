import ./controller_interface
import ../../../../app_service/service/settings/service_interface as settings_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    settingsService: settings_service.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*[T](
  delegate: T,
  settingsService: settings_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface,
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.settingsService = settingsService
  result.walletAccountService = walletAccountService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  discard

method getCurrency*[T](self: Controller[T]): string =
  return self.settingsService.getCurrency()

method getSigningPhrase*[T](self: Controller[T]): string =
  return self.settingsService.getSigningPhrase()

method isMnemonicBackedUp*[T](self: Controller[T]): bool =
  return self.settingsService.getMnemonic().len > 0

method getCurrencyBalance*[T](self: Controller[T]): float64 =
  return self.walletAccountService.getCurrencyBalance()

method updateCurrency*[T](self: Controller[T], currency: string) =
  self.walletAccountService.updateCurrency(currency)
