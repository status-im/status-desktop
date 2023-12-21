import json

import ./io_interface

import app/core/eventemitter
import app_service/service/token/service as token_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/currency/dto
import app_service/service/settings/service as settings_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.Service
    settingsService: settings_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.tokenService = tokenService
  result.walletAccountService = walletAccountService
  result.settingsService = settingsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED) do(e:Args):
    let args = TokenHistoricalDataArgs(e)
    self.delegate.tokenHistoricalDataResolved(args.result)

  self.events.on(SIGNAL_BALANCE_HISTORY_DATA_READY) do(e:Args):
    let args = TokenBalanceHistoryDataArgs(e)
    self.delegate.tokenBalanceHistoryDataResolved(args.result)

proc findTokenSymbolByAddress*(self: Controller, address: string): string =
  return self.walletAccountService.findTokenSymbolByAddress(address)

proc getHistoricalDataForToken*(self: Controller, symbol: string, currency: string, range: int) =
  self.tokenService.getHistoricalDataForToken(symbol, currency, range)

method fetchHistoricalBalanceForTokenAsJson*(self: Controller, addresses: seq[string], allAddresses: bool, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) =
  self.tokenService.fetchHistoricalBalanceForTokenAsJson(addresses, allAddresses, tokenSymbol, currencySymbol, BalanceHistoryTimeInterval(timeIntervalEnum))

proc getSourcesOfTokensList*(self: Controller): var seq[SupportedSourcesItem] =
  return self.tokenService.getSourcesOfTokensList()

proc getFlatTokensList*(self: Controller): var seq[TokenItem] =
  return self.tokenService.getFlatTokensList()

proc getTokenBySymbolList*(self: Controller): var seq[TokenBySymbolItem] =
  return self.tokenService.getTokenBySymbolList()

proc getTokenDetails*(self: Controller, symbol: string): TokenDetailsItem =
  return self.tokenService.getTokenDetails(symbol)

proc getMarketValuesBySymbol*(self: Controller, symbol: string): TokenMarketValuesItem =
  return self.tokenService.getMarketValuesBySymbol(symbol)

proc getPriceBySymbol*(self: Controller, symbol: string): float64 =
  return self.tokenService.getPriceBySymbol(symbol)

proc getCurrentCurrencyFormat*(self: Controller): CurrencyFormatDto =
  return self.walletAccountService.getCurrencyFormat(self.tokenService.getCurrency())

proc rebuildMarketData*(self: Controller) =
  self.tokenService.rebuildMarketData()

proc getTokensDetailsLoading*(self: Controller): bool =
  self.tokenService.getTokensDetailsLoading()

proc getTokensMarketValuesLoading*(self: Controller): bool =
  self.tokenService.getTokensMarketValuesLoading()

proc updateTokenPreferences*(self: Controller, tokenPreferencesJson: string) =
  self.tokenService.updateTokenPreferences(tokenPreferencesJson)

proc getTokenPreferencesJson*(self: Controller): string =
  let data = self.tokenService.getTokenPreferences()
  if data.isNil:
    return "[]"
  return $data

proc getTokenGroupByCommunity*(self: Controller): bool =
  return self.settingsService.tokenGroupByCommunity()

proc toggleTokenGroupByCommunity*(self: Controller) =
  discard self.settingsService.toggleTokenGroupByCommunity()