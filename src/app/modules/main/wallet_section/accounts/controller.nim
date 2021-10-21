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

method generateNewAccount*[T](self: Controller[T], password: string, accountName: string, color: string) =
  self.walletAccountService.generateNewAccount(password, accountName, color)

method addAccountsFromPrivateKey*[T](self: Controller[T], privateKey: string, password: string, accountName: string, color: string) =
  self.walletAccountService.addAccountsFromPrivateKey(privateKey, password, accountName, color)

method addAccountsFromSeed*[T](self: Controller[T], seedPhrase: string, password: string, accountName: string, color: string) =
  self.walletAccountService.addAccountsFromSeed(seedPhrase, password, accountName, color)

method addWatchOnlyAccount*[T](self: Controller[T], address: string, accountName: string, color: string) =
  self.walletAccountService.addWatchOnlyAccount(address, accountName, color)

method deleteAccount*[T](self: Controller[T], address: string) =
  self.walletAccountService.deleteAccount(address)