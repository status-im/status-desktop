import ./controller_interface
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    tokenService: token_service.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*[T](
  delegate: T,
  tokenService: token_service.ServiceInterface,
  walletAccountService: wallet_account_service.ServiceInterface,
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.tokenService = tokenService
  result.walletAccountService = walletAccountService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getTokens*[T](self: Controller[T]): seq[token_service.TokenDto] =
  return self.tokenService.getTokens()

method addCustomToken*[T](self: Controller[T], address: string, name: string, symbol: string, decimals: int) =
  self.tokenService.addCustomToken(address, name, symbol, decimals)
        
method toggleVisible*[T](self: Controller[T], symbol: string) =
  self.walletAccountService.toggleTokenVisible(symbol)

method removeCustomToken*[T](self: Controller[T], address: string) =
  self.tokenService.removeCustomToken(address)