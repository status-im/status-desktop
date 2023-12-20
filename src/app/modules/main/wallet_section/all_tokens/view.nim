import NimQml, sequtils, strutils

import ./io_interface, ./sources_of_tokens_model, ./flat_tokens_model, ./token_by_symbol_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      marketHistoryIsLoading: bool
      balanceHistoryIsLoading: bool
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
    result.balanceHistoryIsLoading = false
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

  proc balanceHistoryIsLoadingChanged*(self: View) {.signal.}
  proc getBalanceHistoryIsLoading(self: View): QVariant {.slot.} =
    return newQVariant(self.balanceHistoryIsLoading)
  proc setBalanceHistoryIsLoading(self: View, isLoading: bool) =
    if self.balanceHistoryIsLoading == isLoading:
      return
    self.balanceHistoryIsLoading = isLoading
    self.balanceHistoryIsLoadingChanged()
  QtProperty[QVariant] balanceHistoryIsLoading:
    read = getBalanceHistoryIsLoading
    notify = balanceHistoryIsLoadingChanged

  proc findTokenSymbolByAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.findTokenSymbolByAddress(address)

  proc getHistoricalDataForToken*(self: View, symbol: string, currency: string) {.slot.} =
    self.setMarketHistoryIsLoading(true)
    self.delegate.getHistoricalDataForToken(symbol, currency)

  proc tokenHistoricalDataReady*(self: View, tokenDetails: string) {.signal.}

  proc setTokenHistoricalDataReady*(self: View, tokenDetails: string) =
    self.setMarketHistoryIsLoading(false)
    self.tokenHistoricalDataReady(tokenDetails)

  proc fetchHistoricalBalanceForTokenAsJson*(self: View, address: string, allAddresses: bool, tokenSymbol: string, currencySymbol: string, timeIntervalEnum: int) {.slot.} =
    self.setBalanceHistoryIsLoading(true)
    self.delegate.fetchHistoricalBalanceForTokenAsJson(address, allAddresses, tokenSymbol, currencySymbol, timeIntervalEnum)

  proc tokenBalanceHistoryDataReady*(self: View, balanceHistoryJson: string) {.signal.}

  proc setTokenBalanceHistoryDataReady*(self: View, balanceHistoryJson: string) =
    self.setBalanceHistoryIsLoading(false)
    self.tokenBalanceHistoryDataReady(balanceHistoryJson)

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

  proc modelsAboutToUpdate*(self: View) =
    self.sourcesOfTokensModel.modelsAboutToUpdate()
    self.flatTokensModel.modelsAboutToUpdate()
    self.tokensBySymbolModel.modelsAboutToUpdate()

  proc modelsUpdated*(self: View) =
    self.sourcesOfTokensModel.modelsUpdated()
    self.flatTokensModel.modelsUpdated()
    self.tokensBySymbolModel.modelsUpdated()

  proc tokensMarketValuesUpdated*(self: View) =
    self.flatTokensModel.tokensMarketValuesUpdated()
    self.tokensBySymbolModel.tokensMarketValuesUpdated()

  proc tokensDetailsUpdated*(self: View) =
    self.flatTokensModel.tokensDetailsUpdated()
    self.tokensBySymbolModel.tokensDetailsUpdated()

  proc currencyFormatsUpdated*(self: View) =
    self.flatTokensModel.currencyFormatsUpdated()
    self.tokensBySymbolModel.currencyFormatsUpdated()

  proc tokenPreferencesUpdated*(self: View, result: bool) {.signal.}

  proc updateTokenPreferences*(self: View, tokenPreferencesJson: string) {.slot.} =
    self.delegate.updateTokenPreferences(tokenPreferencesJson)

  proc getTokenPreferencesJson(self: View): QVariant {.slot.} =
    let preferences = self.delegate.getTokenPreferencesJson()
    return newQVariant(preferences)

  QtProperty[QVariant] tokenPreferencesJson:
    read = getTokenPreferencesJson

  proc tokenGroupByCommunityChanged*(self: View) {.signal.}

  proc getTokenGroupByCommunity(self: View): bool {.slot.} =
    return self.delegate.getTokenGroupByCommunity()

  QtProperty[bool] tokenGroupByCommunity:
    read = getTokenGroupByCommunity
    notify = tokenGroupByCommunityChanged

  proc toggleTokenGroupByCommunity*(self: View) {.slot.} =
    self.delegate.toggleTokenGroupByCommunity()
    self.tokenGroupByCommunityChanged()