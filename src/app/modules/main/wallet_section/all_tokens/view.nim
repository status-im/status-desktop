import nimqml, sequtils, strutils, chronicles

import io_interface, token_lists_model, token_groups_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      marketHistoryIsLoading: bool

      tokenListsModel: TokenListsModel
      tokenGroupsModel: TokenGroupsModel

  ## Forward declaration
  proc modelsUpdated*(self: View)
  proc delete*(self: View)

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.marketHistoryIsLoading = false
    result.tokenListsModel = newTokenListsModel(delegate.getTokenListsModelDataSource())
    result.tokenGroupsModel = newTokenGroupsModel(
      delegate.getTokenGroupsModelDataSource(),
      delegate.getTokenMarketValuesDataSource())

  proc load*(self: View) =
    self.modelsUpdated()
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

  proc getHistoricalDataForToken*(self: View, tokenKey: string, currency: string) {.slot.} =
    self.setMarketHistoryIsLoading(true)
    self.delegate.getHistoricalDataForToken(tokenKey, currency)

  proc tokenHistoricalDataReady*(self: View, tokenDetails: string) {.signal.}

  proc setTokenHistoricalDataReady*(self: View, tokenDetails: string) =
    self.setMarketHistoryIsLoading(false)
    self.tokenHistoricalDataReady(tokenDetails)

  proc tokenListsModelChanged*(self: View) {.signal.}
  proc getTokenListsModel(self: View): QVariant {.slot.} =
    return newQVariant(self.tokenListsModel)
  QtProperty[QVariant] tokenListsModel:
    read = getTokenListsModel
    notify = tokenListsModelChanged

  proc tokenGroupsModelChanged*(self: View) {.signal.}
  proc getTokenGroupsModel(self: View): QVariant {.slot.} =
    return newQVariant(self.tokenGroupsModel)
  QtProperty[QVariant] tokenGroupsModel:
    read = getTokenGroupsModel
    notify = tokenGroupsModelChanged

  proc modelsUpdated*(self: View) =
    self.tokenListsModel.modelsUpdated()
    self.tokenGroupsModel.modelsUpdated()

  proc tokensMarketValuesUpdated*(self: View) =
    self.tokenGroupsModel.tokensMarketValuesUpdated()

  proc tokensMarketValuesAboutToUpdate*(self: View) =
    self.tokenGroupsModel.tokensMarketValuesAboutToUpdate()

  proc tokensDetailsAboutToUpdate*(self: View) =
    self.tokenGroupsModel.tokensDetailsAboutToUpdate()

  proc tokensDetailsUpdated*(self: View) =
    self.tokenGroupsModel.tokensDetailsUpdated()

  proc currencyFormatsUpdated*(self: View) =
    self.tokenGroupsModel.currencyFormatsUpdated()

  proc tokenPreferencesUpdated*(self: View) =
    self.tokenGroupsModel.tokenPreferencesUpdated()

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

  proc tokenAvailableForBridgingViaHop(self: View, tokenChainId: int, tokenAddress: string): bool {.slot.} =
    return self.delegate.tokenAvailableForBridgingViaHop(tokenChainId, tokenAddress)

  proc delete*(self: View) =
    self.QObject.delete

