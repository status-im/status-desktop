import ./controller_interface
import ../../../../app_service/service/setting/service as setting_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    settingService: setting_service.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*[T](
  delegate: T, 
  settingService: setting_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface,
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.settingService = settingService
  result.walletAccountService = walletAccountService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getSetting*[T](self: Controller[T]): setting_service.SettingDto =
  return self.settingService.getSetting()

method getCurrencyBalance*[T](self: Controller[T]): float64 =
  return self.walletAccountService.getCurrencyBalance()