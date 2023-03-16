import NimQml, sequtils, sugar, strutils

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      marketHistoryIsLoading: bool
      balanceHistoryIsLoading: bool

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.marketHistoryIsLoading = false
    result.balanceHistoryIsLoading = false

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

  proc fetchHistoricalBalanceForTokenAsJson*(self: View, address: string, symbol: string, timeIntervalEnum: int) {.slot.} =
    self.setBalanceHistoryIsLoading(true)
    self.delegate.fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum)

  proc tokenBalanceHistoryDataReady*(self: View, balanceHistoryJson: string) {.signal.}

  proc setTokenBalanceHistoryDataReady*(self: View, balanceHistoryJson: string) =
    self.setBalanceHistoryIsLoading(false)
    self.tokenBalanceHistoryDataReady(balanceHistoryJson)
