import tables
import ./controller_interface
import ./io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
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
  
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.delegate.refreshTokens()

method getTokens*(self: Controller): seq[token_service.TokenDto] =
  for tokens in self.tokenService.getTokens().values:
    for token in tokens:
      result.add(token)

method addCustomToken*(self: Controller, chainId: int, address: string, name: string, symbol: string, decimals: int) =
  self.tokenService.addCustomToken(chainId, address, name, symbol, decimals)
        
method toggleVisible*(self: Controller, chainId: int, symbol: string) =
  self.walletAccountService.toggleTokenVisible(chainId, symbol)

method removeCustomToken*(self: Controller, chainId: int, address: string) =
  self.tokenService.removeCustomToken(chainId, address)

method getTokenDetails*(self: Controller, chainId: int, address: string) =
  self.tokenService.getTokenDetails(chainId, address)
