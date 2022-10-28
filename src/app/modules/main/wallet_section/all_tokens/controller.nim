import tables
import algorithm
import ./io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

type
  Controller* = ref object of RootObj
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

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_TOKEN_DETAILS_LOADED) do(e:Args):
    let args = TokenDetailsLoadedArgs(e)
    self.delegate.tokenDetailsWereResolved(args.tokenDetails)
  
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.delegate.refreshTokens()

  self.events.on(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED) do(e:Args):
    let args = TokenHistoricalDataArgs(e)
    self.delegate.tokenHistoricalDataResolved(args.result)

  self.events.on(SIGNAL_BALANCE_HISTORY_DATA_READY) do(e:Args):
    let args = TokenBalanceHistoryDataArgs(e)
    self.delegate.tokenBalanceHistoryDataResolved(args.result)

proc getTokens*(self: Controller): seq[token_service.TokenDto] =
  proc compare(x, y: token_service.TokenDto): int =
    if x.name < y.name:
      return -1
    elif x.name > y.name:
      return 1
    
    return 0

  for tokens in self.tokenService.getTokens().values:
    for token in tokens:
      result.add(token)

  result.sort(compare)

proc addCustomToken*(self: Controller, chainId: int, address: string, name: string, symbol: string, decimals: int): string =
  return self.tokenService.addCustomToken(chainId, address, name, symbol, decimals)
        
proc toggleVisible*(self: Controller, chainId: int, address: string) =
  self.walletAccountService.toggleTokenVisible(chainId, address)

proc removeCustomToken*(self: Controller, chainId: int, address: string) =
  self.tokenService.removeCustomToken(chainId, address)

proc getTokenDetails*(self: Controller, address: string) =
  self.tokenService.getTokenDetails(address)

method findTokenSymbolByAddress*(self: Controller, address: string): string =
  return self.walletAccountService.findTokenSymbolByAddress(address)

method getHistoricalDataForToken*(self: Controller, symbol: string, currency: string, range: int) =
  self.tokenService.getHistoricalDataForToken(symbol, currency, range)

method fetchHistoricalBalanceForTokenAsJson*(self: Controller, address: string, symbol: string, timeIntervalEnum: int) =
  self.tokenService.fetchHistoricalBalanceForTokenAsJson(address, symbol, BalanceHistoryTimeInterval(timeIntervalEnum))