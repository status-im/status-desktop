import ./controller_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*[T](
  delegate: T, 
  walletAccountService: wallet_account_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.walletAccountService = walletAccountService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getWalletAccounts*[T](self: Controller[T]): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()