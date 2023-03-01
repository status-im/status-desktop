import NimQml

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.delegate = delegate
    result.setup()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc networkConnectionStatusUpdate*(self: View, website: string, completelyDown: bool, connectionState: int, chainIds: string, lastCheckedAt: int, timeToAutoRetryInSecs: int, withCache: bool) {.signal.}

  proc refreshBlockchainValues*(self: View) {.slot.} =
    self.delegate.refreshBlockchainValues()

  proc refreshMarketValues*(self: View) {.slot.} =
    self.delegate.refreshMarketValues()

  proc refreshCollectiblesValues*(self: View) {.slot.} =
    self.delegate.refreshCollectiblesValues()

