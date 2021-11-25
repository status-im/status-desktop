import ./controller_interface
import ./io_interface
import eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface,
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.tokenService = tokenService
  result.walletAccountService = walletAccountService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_TOKEN_DETAILS_LOADED) do(e:Args):
    let args = TokenDetailsLoadedArgs(e)
    self.delegate.tokenDetailsWereResolved(args.tokenDetails)

method getTokens*(self: Controller): seq[token_service.TokenDto] =
  return self.tokenService.getTokens()

method addCustomToken*(self: Controller, address: string, name: string, symbol: string, decimals: int) =
  self.tokenService.addCustomToken(address, name, symbol, decimals)
        
method toggleVisible*(self: Controller, symbol: string) =
  self.walletAccountService.toggleTokenVisible(symbol)

method removeCustomToken*(self: Controller, address: string) =
  self.tokenService.removeCustomToken(address)

method getTokenDetails*(self: Controller, address: string) =
  self.tokenService.getTokenDetails(address)