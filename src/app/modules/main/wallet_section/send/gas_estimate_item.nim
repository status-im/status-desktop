import NimQml

QtObject:
  type GasEstimateItem* = ref object of QObject
    totalFeesInEth: float
    totalTokenFees: float
    totalTime: int

  proc setup*(self: GasEstimateItem,
    totalFeesInEth: float,
    totalTokenFees: float,
    totalTime: int
  ) =
    self.QObject.setup
    self.totalFeesInEth = totalFeesInEth
    self.totalTokenFees = totalTokenFees
    self.totalTime = totalTime

  proc delete*(self: GasEstimateItem) =
      self.QObject.delete

  proc newGasEstimateItem*(
    totalFeesInEth: float = 0,
    totalTokenFees: float = 0,
    totalTime: int = 0
    ): GasEstimateItem =
      new(result, delete)
      result.setup(totalFeesInEth, totalTokenFees, totalTime)

  proc `$`*(self: GasEstimateItem): string =
    result = "GasEstimateItem("
    result = result & "\ntotalFeesInEth: " & $self.totalFeesInEth
    result = result & "\ntotalTokenFees: " & $self.totalTokenFees
    result = result & "\ntotalTime: " & $self.totalTime
    result = result & ")"

  proc totalFeesInEthChanged*(self: GasEstimateItem) {.signal.}
  proc getTotalFeesInEth*(self: GasEstimateItem): float {.slot.} =
    return self.totalFeesInEth
  QtProperty[float] totalFeesInEth:
    read = getTotalFeesInEth
    notify = totalFeesInEthChanged

  proc totalTokenFeesChanged*(self: GasEstimateItem) {.signal.}
  proc getTotalTokenFees*(self: GasEstimateItem): float {.slot.} =
    return self.totalTokenFees
  QtProperty[float] totalTokenFees:
    read = getTotalTokenFees
    notify = totalTokenFeesChanged

  proc totalTimeChanged*(self: GasEstimateItem) {.signal.}
  proc getTotalTime*(self: GasEstimateItem): int {.slot.} =
    return self.totalTime
  QtProperty[int] totalTime:
    read = getTotalTime
    notify = totalTimeChanged
