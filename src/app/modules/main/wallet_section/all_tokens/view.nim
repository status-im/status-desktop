import nimqml, sequtils, strutils, chronicles

import ./io_interface, ./sources_of_tokens_model, ./flat_tokens_model, ./token_by_symbol_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      marketHistoryIsLoading: bool

      # This contains the different sources for the tokens list
      # ex. uniswap list, status tokens list
      sourcesOfTokensModel: SourcesOfTokensModel
      # this list contains the complete list of tokens with separate
      # entry per token which has a unique address + network pair */
      flatTokensModel: FlatTokensModel
      # this list contains list of tokens grouped by symbol
      # EXCEPTION: We may have different entries for the same symbol in case
      # of symbol clash when minting community tokens
      tokensBySymbolModel: TokensBySymbolModel

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.marketHistoryIsLoading = false
    result.sourcesOfTokensModel = newSourcesOfTokensModel(delegate.getSourcesOfTokensModelDataSource())
    result.flatTokensModel = newFlatTokensModel(
      delegate.getFlatTokenModelDataSource(),
      delegate.getTokenMarketValuesDataSource())
    result.tokensBySymbolModel = newTokensBySymbolModel(
      delegate.getTokenBySymbolModelDataSource(),
      delegate.getTokenMarketValuesDataSource())

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc marketHistoryIsLoadingChanged*(self: View) {.signal.}
  proc getMarketHistoryIsLoading(self: View): QVariant {.slot.} =
    return newQVariant(self.marketHistoryIsLoading)
  proc setMarketHistoryIsLoading(self: View, isLoading: bool) =
    if self.marketHistoryIsLoading == isLoading:
      return
    self.marketHistoryIsLoading = isLoading
    self.marketHistoryIsLoadingChanged()
  QtProperty[QVariant] marketHistoryIsLoading:
    read = getMarketHistoryIsLoading
    notify = marketHistoryIsLoadingChanged

  proc getTokenListUpdatedAt(self: View): QVariant {.slot.} =
    return newQVariant(self.delegate.getLastTokensUpdate())
  proc tokenListUpdatedAtChanged(self: View) {.signal.}
  proc emitTokenListUpdatedAtSignal*(self: View) =
    self.tokenListUpdatedAtChanged()
  QtProperty[QVariant] tokenListUpdatedAt:
    read = getTokenListUpdatedAt
    notify = tokenListUpdatedAtChanged

  proc getHistoricalDataForToken*(self: View, symbol: string, currency: string) {.slot.} =
    self.setMarketHistoryIsLoading(true)
    self.delegate.getHistoricalDataForToken(symbol, currency)

  proc tokenHistoricalDataReady*(self: View, tokenDetails: string) {.signal.}

  proc setTokenHistoricalDataReady*(self: View, tokenDetails: string) =
    self.setMarketHistoryIsLoading(false)
    self.tokenHistoricalDataReady(tokenDetails)

  proc sourcesOfTokensModelChanged*(self: View) {.signal.}
  proc getSourcesOfTokensModel(self: View): QVariant {.slot.} =
    return newQVariant(self.sourcesOfTokensModel)
  QtProperty[QVariant] sourcesOfTokensModel:
    read = getSourcesOfTokensModel
    notify = sourcesOfTokensModelChanged

  proc flatTokensModelChanged*(self: View) {.signal.}
  proc getFlatTokensModel(self: View): QVariant {.slot.} =
    return newQVariant(self.flatTokensModel)
  QtProperty[QVariant] flatTokensModel:
    read = getFlatTokensModel
    notify = flatTokensModelChanged

  proc tokensBySymbolModelChanged*(self: View) {.signal.}
  proc getTokensBySymbolModel(self: View): QVariant {.slot.} =
    return newQVariant(self.tokensBySymbolModel)
  QtProperty[QVariant] tokensBySymbolModel:
    read = getTokensBySymbolModel
    notify = tokensBySymbolModelChanged

  proc modelsUpdated*(self: View) =
    self.sourcesOfTokensModel.modelsUpdated()
    self.flatTokensModel.modelsUpdated()
    self.tokensBySymbolModel.modelsUpdated()

  proc tokensMarketValuesUpdated*(self: View) =
    self.flatTokensModel.tokensMarketValuesUpdated()
    self.tokensBySymbolModel.tokensMarketValuesUpdated()

  proc tokensMarketValuesAboutToUpdate*(self: View) =
    self.flatTokensModel.tokensMarketValuesAboutToUpdate()
    self.tokensBySymbolModel.tokensMarketValuesAboutToUpdate()

  proc tokensDetailsAboutToUpdate*(self: View) =
    self.flatTokensModel.tokensDetailsAboutToUpdate()
    self.tokensBySymbolModel.tokensDetailsAboutToUpdate()

  proc tokensDetailsUpdated*(self: View) =
    self.flatTokensModel.tokensDetailsUpdated()
    self.tokensBySymbolModel.tokensDetailsUpdated()

  proc currencyFormatsUpdated*(self: View) =
    self.flatTokensModel.currencyFormatsUpdated()
    self.tokensBySymbolModel.currencyFormatsUpdated()

  proc tokenPreferencesUpdated*(self: View) =
    self.flatTokensModel.tokenPreferencesUpdated()
    self.tokensBySymbolModel.tokenPreferencesUpdated()

  proc updateTokenPreferences*(self: View, tokenPreferencesJson: string) {.slot.} =
    self.delegate.updateTokenPreferences(tokenPreferencesJson)

  proc getTokenPreferencesJson(self: View): string {.slot.} =
    let preferences = self.delegate.getTokenPreferencesJson()
    return preferences

  QtProperty[string] tokenPreferencesJson:
    read = getTokenPreferencesJson

  proc tokenGroupByCommunityChanged*(self: View) {.signal.}

  proc getTokenGroupByCommunity(self: View): bool {.slot.} =
    return self.delegate.getTokenGroupByCommunity()

  QtProperty[bool] tokenGroupByCommunity:
    read = getTokenGroupByCommunity
    notify = tokenGroupByCommunityChanged

  proc toggleTokenGroupByCommunity*(self: View): bool {.slot.} =
    if not self.delegate.toggleTokenGroupByCommunity():
      error "Failed to toggle tokenGroupByCommunity"
      return
    self.tokenGroupByCommunityChanged()

  proc showCommunityAssetWhenSendingTokensChanged*(self: View) {.signal.}

  proc getShowCommunityAssetWhenSendingTokens(self: View): bool {.slot.} =
    return self.delegate.getShowCommunityAssetWhenSendingTokens()

  QtProperty[bool] showCommunityAssetWhenSendingTokens:
    read = getShowCommunityAssetWhenSendingTokens
    notify = showCommunityAssetWhenSendingTokensChanged

  proc toggleShowCommunityAssetWhenSendingTokens*(self: View) {.slot.} =
    if not self.delegate.toggleShowCommunityAssetWhenSendingTokens():
      error "Failed to toggle showCommunityAssetWhenSendingTokens"
      return
    self.showCommunityAssetWhenSendingTokensChanged()

  proc displayAssetsBelowBalanceChanged*(self: View) {.signal.}

  proc getDisplayAssetsBelowBalance(self: View): bool {.slot.} =
    return self.delegate.getDisplayAssetsBelowBalance()

  QtProperty[bool] displayAssetsBelowBalance:
    read = getDisplayAssetsBelowBalance
    notify = displayAssetsBelowBalanceChanged

  proc toggleDisplayAssetsBelowBalance*(self: View) {.slot.} =
    if not self.delegate.toggleDisplayAssetsBelowBalance():
      error "Failed to toggle displayAssetsBelowBalance"
      return
    self.displayAssetsBelowBalanceChanged()

  proc displayAssetsBelowBalanceThresholdChanged*(self: View) {.signal.}

  proc getDisplayAssetsBelowBalanceThreshold(self: View): QVariant {.slot.} =
    return newQVariant(self.delegate.getDisplayAssetsBelowBalanceThreshold())

  proc setDisplayAssetsBelowBalanceThreshold(self: View, threshold: string) {.slot.} =
    var num: int64
    try:
      num = parseInt(threshold)
    except ValueError:
      error "Failed to parse displayAssetsBelowBalanceThreshold"
      return
    if not self.delegate.setDisplayAssetsBelowBalanceThreshold(num):
      error "Failed to set displayAssetsBelowBalanceThreshold"
      return
    self.displayAssetsBelowBalanceThresholdChanged()

  QtProperty[QVariant] displayAssetsBelowBalanceThreshold:
    read = getDisplayAssetsBelowBalanceThreshold
    notify = displayAssetsBelowBalanceThresholdChanged


  proc autoRefreshTokensListsChanged(self: View) {.signal.}
  proc emitAutoRefreshTokensListsChanged*(self: View) =
    self.autoRefreshTokensListsChanged()
  proc getAutoRefreshTokensLists(self: View): bool {.slot.} =
    return self.delegate.getAutoRefreshTokensLists()
  proc toggleAutoRefreshTokensLists(self: View) {.slot.} =
    self.delegate.toggleAutoRefreshTokensLists()
    self.autoRefreshTokensListsChanged()
  QtProperty[bool] autoRefreshTokensLists:
    read = getAutoRefreshTokensLists
    notify = autoRefreshTokensListsChanged