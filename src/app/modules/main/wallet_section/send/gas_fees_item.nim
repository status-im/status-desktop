import NimQml

QtObject:
  type GasFeesItem* = ref object of QObject
    gasPrice: float
    baseFee: float
    maxPriorityFeePerGas: float
    maxFeePerGasL: float
    maxFeePerGasM: float
    maxFeePerGasH: float
    eip1559Enabled: bool

  proc setup*(self: GasFeesItem,
    gasPrice: float,
    baseFee: float,
    maxPriorityFeePerGas: float,
    maxFeePerGasL: float,
    maxFeePerGasM: float,
    maxFeePerGasH: float,
    eip1559Enabled: bool
  ) =
    self.QObject.setup
    self.gasPrice = gasPrice
    self.baseFee = baseFee
    self.maxPriorityFeePerGas = maxPriorityFeePerGas
    self.maxFeePerGasL = maxFeePerGasL
    self.maxFeePerGasM = maxFeePerGasM
    self.maxFeePerGasH = maxFeePerGasH
    self.eip1559Enabled = eip1559Enabled

  proc delete*(self: GasFeesItem) =
      self.QObject.delete

  proc newGasFeesItem*(
    gasPrice: float = 0,
    baseFee: float = 0,
    maxPriorityFeePerGas: float = 0,
    maxFeePerGasL: float = 0,
    maxFeePerGasM: float = 0,
    maxFeePerGasH: float = 0,
    eip1559Enabled: bool = false
    ): GasFeesItem =
      new(result, delete)
      result.setup(gasPrice, baseFee, maxPriorityFeePerGas, maxFeePerGasL, maxFeePerGasM, maxFeePerGasH, eip1559Enabled)

  proc `$`*(self: GasFeesItem): string =
    result = "GasFeesItem("
    result = result & "\ngasPrice: " & $self.gasPrice
    result = result & "\nbaseFee: " & $self.baseFee
    result = result & "\nmaxPriorityFeePerGas: " & $self.maxPriorityFeePerGas
    result = result & "\nmaxFeePerGasL: " & $self.maxFeePerGasL
    result = result & "\nmaxFeePerGasM: " & $self.maxFeePerGasM
    result = result & "\nmaxFeePerGasH: " & $self.maxFeePerGasH
    result = result & "\neip1559Enabled: " & $self.eip1559Enabled
    result = result & ")"

  proc gasPriceChanged*(self: GasFeesItem) {.signal.}
  proc getGasPrice*(self: GasFeesItem): float {.slot.} =
    return self.gasPrice
  QtProperty[float] gasPrice:
    read = getGasPrice
    notify = gasPriceChanged

  proc baseFeeChanged*(self: GasFeesItem) {.signal.}
  proc getBaseFee*(self: GasFeesItem): float {.slot.} =
    return self.baseFee
  QtProperty[float] baseFee:
    read = getBaseFee
    notify = baseFeeChanged

  proc maxPriorityFeePerGasChanged*(self: GasFeesItem) {.signal.}
  proc getMaxPriorityFeePerGas*(self: GasFeesItem): float {.slot.} =
    return self.maxPriorityFeePerGas
  QtProperty[float] maxPriorityFeePerGas:
    read = getMaxPriorityFeePerGas
    notify = maxPriorityFeePerGasChanged

  proc maxFeePerGasLChanged*(self: GasFeesItem) {.signal.}
  proc getMaxFeePerGasL*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasL
  QtProperty[float] maxFeePerGasL:
    read = getMaxFeePerGasL
    notify = maxFeePerGasLChanged

  proc maxFeePerGasMChanged*(self: GasFeesItem) {.signal.}
  proc getMaxFeePerGasM*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasM
  QtProperty[float] maxFeePerGasM:
    read = getMaxFeePerGasM
    notify = maxFeePerGasMChanged

  proc maxFeePerGasHChanged*(self: GasFeesItem) {.signal.}
  proc getMaxFeePerGasH*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasH
  QtProperty[float] maxFeePerGasH:
    read = getMaxFeePerGasH
    notify = maxFeePerGasHChanged

  proc eip1559EnabledChanged*(self: GasFeesItem) {.signal.}
  proc getEip1559Enabled*(self: GasFeesItem): bool {.slot.} =
    return self.eip1559Enabled
  QtProperty[bool] eip1559Enabled:
    read = getEip1559Enabled
    notify = eip1559EnabledChanged
