import NimQml, sequtils, sugar, strutils

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc findTokenSymbolByAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.findTokenSymbolByAddress(address)

  proc getHistoricalDataForToken*(self: View, symbol: string, currency: string) {.slot.} =
    self.delegate.getHistoricalDataForToken(symbol, currency)

  proc tokenHistoricalDataReady*(self: View, tokenDetails: string) {.signal.}

  proc fetchHistoricalBalanceForTokenAsJson*(self: View, address: string, symbol: string, timeIntervalEnum: int) {.slot.} =
    self.delegate.fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum)

  proc tokenBalanceHistoryDataReady*(self: View, balanceHistoryJson: string) {.signal.}