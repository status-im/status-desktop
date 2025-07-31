import nimqml

QtObject:
  type GasEstimateItem* = ref object of QObject
    totalFeesInNativeCrypto: float
    totalTokenFees: float
    totalTime: int

  proc setup*(self: GasEstimateItem,
    totalFeesInNativeCrypto: float,
    totalTokenFees: float,
    totalTime: int
  ) =
    self.QObject.setup
    self.totalFeesInNativeCrypto = totalFeesInNativeCrypto
    self.totalTokenFees = totalTokenFees
    self.totalTime = totalTime

  proc delete*(self: GasEstimateItem) =
      self.QObject.delete

  proc newGasEstimateItem*(
    totalFeesInNativeCrypto: float = 0,
    totalTokenFees: float = 0,
    totalTime: int = 0
    ): GasEstimateItem =
      new(result, delete)
      result.setup(totalFeesInNativeCrypto, totalTokenFees, totalTime)

  proc `$`*(self: GasEstimateItem): string =
    result = "GasEstimateItem("
    result = result & "\totalFeesInNativeCrypto: " & $self.totalFeesInNativeCrypto
    result = result & "\ntotalTokenFees: " & $self.totalTokenFees
    result = result & "\ntotalTime: " & $self.totalTime
    result = result & ")"

  proc totalFeesInNativeCryptoChanged*(self: GasEstimateItem) {.signal.}
  proc getTotalFeesInNativeCrypto*(self: GasEstimateItem): float {.slot.} =
    return self.totalFeesInNativeCrypto
  QtProperty[float] totalFeesInNativeCrypto:
    read = getTotalFeesInNativeCrypto
    notify = totalFeesInNativeCryptoChanged

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
