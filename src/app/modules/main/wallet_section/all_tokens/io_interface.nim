import app_service/service/token/service_items
import app_service/service/currency/dto
import app/modules/shared_models/currency_amount

type
  SourcesOfTokensModelDataSource* = tuple[
    getSourcesOfTokensList: proc(): var seq[SupportedSourcesItem]
  ]
type
  FlatTokenModelDataSource* = tuple[
    getFlatTokensList: proc(): var seq[TokenItem],
    getTokenDetails: proc(symbol: string): TokenDetailsItem,
    getTokenPreferences: proc(symbol: string): TokenPreferencesItem,
    getCommunityTokenDescription: proc(chainId: int, address: string): string,
    getTokensDetailsLoading: proc(): bool,
    getTokensMarketValuesLoading: proc(): bool,
  ]
type
  TokenBySymbolModelDataSource* = tuple[
    getTokenBySymbolList: proc(): var seq[TokenBySymbolItem],
    getTokenDetails: proc(symbol: string): TokenDetailsItem,
    getTokenPreferences: proc(symbol: string): TokenPreferencesItem,
    getCommunityTokenDescription: proc(addressPerChain: seq[AddressPerChain]): string,
    getTokensDetailsLoading: proc(): bool,
    getTokensMarketValuesLoading: proc(): bool,
  ]
type
  TokenMarketValuesDataSource* = tuple[
    getMarketValuesBySymbol: proc(symbol: string): TokenMarketValuesItem,
    getPriceBySymbol: proc(symbol: string): float64,
    getCurrentCurrencyFormat: proc(): CurrencyFormatDto,
    getTokensMarketValuesLoading: proc(): bool
  ]
type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getHistoricalDataForToken*(self: AccessInterface, symbol: string, currency: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method tokenHistoricalDataResolved*(self: AccessInterface, tokenDetails: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSourcesOfTokensModelDataSource*(self: AccessInterface): SourcesOfTokensModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method getFlatTokenModelDataSource*(self: AccessInterface): FlatTokenModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenBySymbolModelDataSource*(self: AccessInterface): TokenBySymbolModelDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenMarketValuesDataSource*(self: AccessInterface): TokenMarketValuesDataSource {.base.} =
  raise newException(ValueError, "No implementation available")

method updateTokenPreferences*(self: AccessInterface, tokenPreferencesJson: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenPreferencesJson*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(self: AccessInterface, addresses: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenGroupByCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleTokenGroupByCommunity*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getShowCommunityAssetWhenSendingTokens*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleShowCommunityAssetWhenSendingTokens*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getDisplayAssetsBelowBalance*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleDisplayAssetsBelowBalance*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getDisplayAssetsBelowBalanceThreshold*(self: AccessInterface): CurrencyAmount {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayAssetsBelowBalanceThreshold*(self: AccessInterface, threshold: int64): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getLastTokensUpdate*(self: AccessInterface): int64 {.base.} =
  raise newException(ValueError, "No implementation available")

method getAutoRefreshTokensLists*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleAutoRefreshTokensLists*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method displayAssetsBelowBalanceChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method displayAssetsBelowBalanceThresholdChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method showCommunityAssetWhenSendingTokensChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
