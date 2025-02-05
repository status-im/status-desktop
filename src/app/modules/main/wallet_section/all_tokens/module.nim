import NimQml

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app/modules/shared_models/currency_amount
import app_service/service/token/service as token_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/dto
import app_service/service/currency/service
import app_service/service/settings/service as settings_service
import app_service/service/community_tokens/service as community_tokens_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    addresses: seq[string]
    modelUpdatedSubscribers: seq[proc()]
    tokensDetailsUpdatedSubscribers: seq[proc()]
    tokensMarketValuesUpdatedSubscribers: seq[proc()]
    tokenPreferencesUpdatedSubscribers: seq[proc()]
    currencyFormatsUpdatedSubscribers: seq[proc()]

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  communityTokensService: community_tokens_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, tokenService, walletAccountService, settingsService, communityTokensService)
  result.moduleLoaded = false
  result.addresses = @[]

method delete*(self: Module) =
  self.viewVariant.delete
  self.view.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAllTokens", self.viewVariant)

  self.events.on(SIGNAL_CURRENCY_UPDATED) do(e:Args):
    self.controller.rebuildMarketData()

  # Passing on the events for changes in model to abstract model
  self.events.on(SIGNAL_TOKENS_LIST_UPDATED) do(e: Args):
    self.view.setTokenListUpdatedAt(self.controller.getTokenListUpdatedAt())
    for modelUpdatedSubscriber in self.modelUpdatedSubscribers:
      modelUpdatedSubscriber()
  self.events.on(SIGNAL_TOKENS_DETAILS_UPDATED) do(e: Args):
    for tokensDetailsUpdatedSubscriber in self.tokensDetailsUpdatedSubscribers:
      tokensDetailsUpdatedSubscriber()
  self.events.on(SIGNAL_TOKENS_MARKET_VALUES_UPDATED) do(e: Args):
    for tokensMarketValuesUpdatedSubscriber in self.tokensMarketValuesUpdatedSubscribers:
      tokensMarketValuesUpdatedSubscriber()
  self.events.on(SIGNAL_TOKENS_PRICES_UPDATED) do(e: Args):
    for tokensMarketValuesUpdatedSubscriber in self.tokensMarketValuesUpdatedSubscribers:
      tokensMarketValuesUpdatedSubscriber()
  self.events.on(SIGNAL_TOKEN_PREFERENCES_UPDATED) do(e: Args):
    for tokenPreferencesUpdatedSubscriber in self.tokenPreferencesUpdatedSubscribers:
      tokenPreferencesUpdatedSubscriber()
  self.events.on(SIGNAL_COMMUNITY_TOKENS_DETAILS_LOADED) do(e: Args):
    for tokensDetailsUpdatedSubscriber in self.tokensDetailsUpdatedSubscribers:
      tokensDetailsUpdatedSubscriber()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    for currencyFormatsUpdatedSubscriber in self.currencyFormatsUpdatedSubscribers:
      currencyFormatsUpdatedSubscriber()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.allTokensModuleDidLoad()

method getHistoricalDataForToken*(self: Module, symbol: string, currency: string) =
  self.controller.getHistoricalDataForToken(symbol, currency, WEEKLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, MONTHLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, HALF_YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, ALL_TIME_RANGE)

method tokenHistoricalDataResolved*(self: Module, tokenDetails: string) =
  self.view.setTokenHistoricalDataReady(tokenDetails)

method fetchHistoricalBalanceForTokenAsJson*(self: Module, address: string, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) =
  let addresses = if address == "": self.addresses else: @[address]
  self.controller.fetchHistoricalBalanceForTokenAsJson(addresses, tokenSymbol, currencySymbol,timeIntervalEnum)

method tokenBalanceHistoryDataResolved*(self: Module, balanceHistoryJson: string) =
  self.view.setTokenBalanceHistoryDataReady(balanceHistoryJson)

# Interfaces for getting lists from the service files into the abstract models

method getSourcesOfTokensModelDataSource*(self: Module): SourcesOfTokensModelDataSource =
  return (
    getSourcesOfTokensList: proc(): var seq[SupportedSourcesItem] = self.controller.getSourcesOfTokensList(),
    subscribeToModelUpdates: proc(callback: proc()) = self.modelUpdatedSubscribers.add(callback)
  )

method getFlatTokenModelDataSource*(self: Module): FlatTokenModelDataSource =
  return (
    getFlatTokensList: proc(): var seq[TokenItem] = self.controller.getFlatTokensList(),
    getTokenDetails: proc(symbol: string): TokenDetailsItem = self.controller.getTokenDetails(symbol),
    getTokenPreferences: proc(symbol: string): TokenPreferencesItem = self.controller.getTokenPreferences(symbol),
    getCommunityTokenDescription: proc(chainId: int, address: string): string = self.controller.getCommunityTokenDescription(chainId, address),
    getTokensDetailsLoading: proc(): bool = self.controller.getTokensDetailsLoading(),
    getTokensMarketValuesLoading: proc(): bool = self.controller.getTokensMarketValuesLoading(),
    subscribeToModelUpdates: proc(callback: proc()) = self.modelUpdatedSubscribers.add(callback),
    subscribeToTokenDetailsUpdates: proc(callback: proc()) = self.tokensDetailsUpdatedSubscribers.add(callback),
    subscribeToTokenMarketValuesUpdates: proc(callback: proc()) = self.tokensMarketValuesUpdatedSubscribers.add(callback),
    subscribeToTokenPreferencesUpdates: proc(callback: proc()) = self.tokenPreferencesUpdatedSubscribers.add(callback),
    subscribeToCurrencyFormatsUpdates: proc(callback: proc()) = self.currencyFormatsUpdatedSubscribers.add(callback)
  )

method getTokenBySymbolModelDataSource*(self: Module): TokenBySymbolModelDataSource =
  return (
    getTokenBySymbolList: proc(): var seq[TokenBySymbolItem] = self.controller.getTokenBySymbolList(),
    getTokenDetails: proc(symbol: string): TokenDetailsItem = self.controller.getTokenDetails(symbol),
    getTokenPreferences: proc(symbol: string): TokenPreferencesItem = self.controller.getTokenPreferences(symbol),
    getCommunityTokenDescription: proc(addressPerChain: seq[AddressPerChain]): string = self.controller.getCommunityTokenDescription(addressPerChain),
    getTokensDetailsLoading: proc(): bool = self.controller.getTokensDetailsLoading(),
    getTokensMarketValuesLoading: proc(): bool = self.controller.getTokensMarketValuesLoading(),
    subscribeToModelUpdates: proc(callback: proc()) = self.modelUpdatedSubscribers.add(callback),
    subscribeToTokenDetailsUpdates: proc(callback: proc()) = self.tokensDetailsUpdatedSubscribers.add(callback),
    subscribeToTokenMarketValuesUpdates: proc(callback: proc()) = self.tokensMarketValuesUpdatedSubscribers.add(callback),
    subscribeToTokenPreferencesUpdates: proc(callback: proc()) = self.tokenPreferencesUpdatedSubscribers.add(callback),
    subscribeToCurrencyFormatsUpdates: proc(callback: proc()) = self.currencyFormatsUpdatedSubscribers.add(callback)
  )

method getTokenMarketValuesDataSource*(self: Module): TokenMarketValuesDataSource =
  return (
    getMarketValuesBySymbol: proc(symbol: string): TokenMarketValuesItem = self.controller.getMarketValuesBySymbol(symbol),
    getPriceBySymbol: proc(symbol: string): float64 = self.controller.getPriceBySymbol(symbol),
    getCurrentCurrencyFormat: proc(): CurrencyFormatDto = self.controller.getCurrentCurrencyFormat(),
    getTokensMarketValuesLoading: proc(): bool = self.controller.getTokensMarketValuesLoading()
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

method toggleTokenGroupByCommunity*(self: Module): bool =
  return self.controller.toggleTokenGroupByCommunity()

method getShowCommunityAssetWhenSendingTokens*(self: Module): bool =
  return self.controller.getShowCommunityAssetWhenSendingTokens()

method toggleShowCommunityAssetWhenSendingTokens*(self: Module): bool =
  return self.controller.toggleShowCommunityAssetWhenSendingTokens()

method getDisplayAssetsBelowBalance*(self: Module): bool =
  return self.controller.getDisplayAssetsBelowBalance()

method toggleDisplayAssetsBelowBalance*(self: Module): bool =
  return self.controller.toggleDisplayAssetsBelowBalance()

method getDisplayAssetsBelowBalanceThreshold*(self: Module): CurrencyAmount =
  return self.controller.getDisplayAssetsBelowBalanceThreshold()

method setDisplayAssetsBelowBalanceThreshold*(self: Module, threshold: int64): bool =
  return self.controller.setDisplayAssetsBelowBalanceThreshold(threshold)
