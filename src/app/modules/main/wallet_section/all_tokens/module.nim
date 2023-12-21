import NimQml

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/token/service as token_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/dto
import app_service/service/currency/service
import app_service/service/settings/service as settings_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    addresses: seq[string]

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, events, tokenService, walletAccountService, settingsService)
  result.moduleLoaded = false
  result.addresses = @[]

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAllTokens", newQVariant(self.view))

  self.events.on(SIGNAL_CURRENCY_UPDATED) do(e:Args):
    self.controller.rebuildMarketData()
  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.controller.rebuildMarketData()

  # Passing on the events for changes in model to abstract model
  self.events.on(SIGNAL_TOKENS_LIST_ABOUT_TO_BE_UPDATED) do(e: Args):
    self.view.modelsAboutToUpdate()
  self.events.on(SIGNAL_TOKENS_LIST_UPDATED) do(e: Args):
    self.view.modelsUpdated()
  self.events.on(SIGNAL_TOKENS_DETAILS_UPDATED) do(e: Args):
    self.view.tokensDetailsUpdated()
  self.events.on(SIGNAL_TOKENS_MARKET_VALUES_UPDATED) do(e: Args):
    self.view.tokensMarketValuesUpdated()
  self.events.on(SIGNAL_TOKENS_PRICES_UPDATED) do(e: Args):
    self.view.tokensMarketValuesUpdated()
  self.events.on(SIGNAL_TOKEN_PREFERENCES_UPDATED) do(e: Args):
    let args = ResultArgs(e)
    self.view.tokenPreferencesUpdated(args.success)

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.view.currencyFormatsUpdated()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.allTokensModuleDidLoad()

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)

method getHistoricalDataForToken*(self: Module, symbol: string, currency: string) =
  self.controller.getHistoricalDataForToken(symbol, currency, WEEKLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, MONTHLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, HALF_YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, ALL_TIME_RANGE)

method tokenHistoricalDataResolved*(self: Module, tokenDetails: string) =
  self.view.setTokenHistoricalDataReady(tokenDetails)

method fetchHistoricalBalanceForTokenAsJson*(self: Module, address: string, allAddresses: bool, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) =
  let addresses = if allAddresses: self.addresses else: @[address]
  self.controller.fetchHistoricalBalanceForTokenAsJson(addresses, allAddresses, tokenSymbol, currencySymbol,timeIntervalEnum)

method tokenBalanceHistoryDataResolved*(self: Module, balanceHistoryJson: string) =
  self.view.setTokenBalanceHistoryDataReady(balanceHistoryJson)

# Interfaces for getting lists from the service files into the abstract models

method getSourcesOfTokensModelDataSource*(self: Module): SourcesOfTokensModelDataSource =
  return (
    getSourcesOfTokensList: proc(): var seq[SupportedSourcesItem] = self.controller.getSourcesOfTokensList()
  )

method getFlatTokenModelDataSource*(self: Module): FlatTokenModelDataSource =
  return (
    getFlatTokensList: proc(): var seq[TokenItem] = self.controller.getFlatTokensList(),
    getTokenDetails: proc(symbol: string): TokenDetailsItem = self.controller.getTokenDetails(symbol),
    getTokensDetailsLoading: proc(): bool = self.controller.getTokensDetailsLoading(),
    getTokensMarketValuesLoading: proc(): bool = self.controller.getTokensMarketValuesLoading()
  )

method getTokenBySymbolModelDataSource*(self: Module): TokenBySymbolModelDataSource =
  return (
    getTokenBySymbolList: proc(): var seq[TokenBySymbolItem] = self.controller.getTokenBySymbolList(),
    getTokenDetails: proc(symbol: string): TokenDetailsItem = self.controller.getTokenDetails(symbol),
    getTokensDetailsLoading: proc(): bool = self.controller.getTokensDetailsLoading(),
    getTokensMarketValuesLoading: proc(): bool = self.controller.getTokensMarketValuesLoading()
  )

method getTokenMarketValuesDataSource*(self: Module): TokenMarketValuesDataSource =
  return (
    getMarketValuesBySymbol: proc(symbol: string): TokenMarketValuesItem = self.controller.getMarketValuesBySymbol(symbol),
    getPriceBySymbol: proc(symbol: string): float64 = self.controller.getPriceBySymbol(symbol),
    getCurrentCurrencyFormat: proc(): CurrencyFormatDto = self.controller.getCurrentCurrencyFormat()
  )

method filterChanged*(self: Module, addresses: seq[string]) = 
  if addresses == self.addresses:
      return
  self.addresses = addresses

method updateTokenPreferences*(self: Module, tokenPreferencesJson: string) {.slot.} =
  self.controller.updateTokenPreferences(tokenPreferencesJson)

method getTokenPreferencesJson*(self: Module): string =
  return self.controller.getTokenPreferencesJson()

method getTokenGroupByCommunity*(self: Module): bool =
  return self.controller.getTokenGroupByCommunity()

method toggleTokenGroupByCommunity*(self: Module) =
  self.controller.toggleTokenGroupByCommunity()