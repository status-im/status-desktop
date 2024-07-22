import ./io_interface

import app/core/eventemitter
import app_service/service/token/service as token_service
import app_service/service/wallet_account/service as wallet_account_service
import app/modules/shared_models/currency_amount
import app_service/service/currency/dto
import app_service/service/settings/service as settings_service
import app_service/service/community_tokens/service as community_tokens_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    tokenService: token_service.Service
    walletAccountService: wallet_account_service.Service
    settingsService: settings_service.Service
    communityTokensService: community_tokens_service.Service
    displayAssetsBelowBalanceThreshold: CurrencyAmount

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  communityTokensService: community_tokens_service.Service
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.tokenService = tokenService
  result.walletAccountService = walletAccountService
  result.settingsService = settingsService
  result.communityTokensService = communityTokensService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_TOKEN_HISTORICAL_DATA_LOADED) do(e:Args):
    let args = TokenHistoricalDataArgs(e)
    self.delegate.tokenHistoricalDataResolved(args.result)

  self.events.on(SIGNAL_BALANCE_HISTORY_DATA_READY) do(e:Args):
    let args = TokenBalanceHistoryDataArgs(e)
    self.delegate.tokenBalanceHistoryDataResolved(args.result)

  self.events.on(SIGNAL_COMMUNITY_TOKEN_RECEIVED) do(e: Args):
    let args = CommunityTokenReceivedArgs(e)
    let token = TokenDto(
        address: args.address,
        name: args.name,
        symbol: args.symbol,
        decimals: args.decimals,
        chainID: args.chainId,
        communityID: args.communityId,
        image: args.image,
    )
    self.tokenService.addNewCommunityToken(token)

  self.tokenService.getSupportedTokensList()

proc getHistoricalDataForToken*(self: Controller, symbol: string, currency: string, range: int) =
  self.tokenService.getHistoricalDataForToken(symbol, currency, range)

proc fetchHistoricalBalanceForTokenAsJson*(self: Controller, addresses: seq[string], tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) =
  self.walletAccountService.fetchHistoricalBalanceForTokenAsJson(addresses, tokenSymbol, currencySymbol, BalanceHistoryTimeInterval(timeIntervalEnum))

proc getSourcesOfTokensList*(self: Controller): var seq[SupportedSourcesItem] =
  return self.tokenService.getSourcesOfTokensList()

proc getFlatTokensList*(self: Controller): var seq[TokenItem] =
  return self.tokenService.getFlatTokensList()

proc getTokenBySymbolList*(self: Controller): var seq[TokenBySymbolItem] =
  return self.tokenService.getTokenBySymbolList()

proc getTokenDetails*(self: Controller, symbol: string): TokenDetailsItem =
  return self.tokenService.getTokenDetails(symbol)

proc getTokenListUpdatedAt*(self: Controller): int64 =
  return self.tokenService.getTokenListUpdatedAt()

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

proc getCommunityTokenDescription*(self: Controller, addressPerChain: seq[AddressPerChain]): string =
  self.communityTokensService.getCommunityTokenDescription(addressPerChain)

proc getCommunityTokenDescription*(self: Controller, chainId: int, address: string): string =
  self.communityTokensService.getCommunityTokenDescription(chainId, address)

proc updateTokenPreferences*(self: Controller, tokenPreferencesJson: string) =
  self.tokenService.updateTokenPreferences(tokenPreferencesJson)

proc getTokenPreferences*(self: Controller, symbol: string): TokenPreferencesItem =
  return self.tokenService.getTokenPreferences(symbol)

proc getTokenPreferencesJson*(self: Controller): string =
  return self.tokenService.getTokenPreferencesJson()

proc getTokenGroupByCommunity*(self: Controller): bool =
  return self.settingsService.tokenGroupByCommunity()

proc toggleTokenGroupByCommunity*(self: Controller): bool =
  return self.settingsService.toggleTokenGroupByCommunity()

proc getShowCommunityAssetWhenSendingTokens*(self: Controller): bool =
  return self.settingsService.showCommunityAssetWhenSendingTokens()

proc toggleShowCommunityAssetWhenSendingTokens*(self: Controller): bool =
  return self.settingsService.toggleShowCommunityAssetWhenSendingTokens()

proc getDisplayAssetsBelowBalance*(self: Controller): bool =
  return self.settingsService.displayAssetsBelowBalance()

proc toggleDisplayAssetsBelowBalance*(self: Controller): bool =
  return self.settingsService.toggleDisplayAssetsBelowBalance()

proc getDisplayAssetsBelowBalanceThreshold*(self: Controller): CurrencyAmount =
  let amount = float64(self.settingsService.displayAssetsBelowBalanceThreshold())
  self.displayAssetsBelowBalanceThreshold = newCurrencyAmount(amount, self.tokenService.getCurrency(), 9, true)
  return self.displayAssetsBelowBalanceThreshold

proc setDisplayAssetsBelowBalanceThreshold*(self: Controller, threshold: int64): bool =
  return self.settingsService.setDisplayAssetsBelowBalanceThreshold(threshold)
