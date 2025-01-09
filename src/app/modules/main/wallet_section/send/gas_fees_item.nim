import NimQml

QtObject:
  type GasFeesItem* = ref object of QObject
    gasPrice: float
    baseFee: float
    maxPriorityFeePerGas: float
    maxFeePerGasL: float
    maxFeePerGasM: float
    maxFeePerGasH: float
    l1GasFee: float
    eip1559Enabled: bool

  proc setup*(
      self: GasFeesItem,
      gasPrice: float,
      baseFee: float,
      maxPriorityFeePerGas: float,
      maxFeePerGasL: float,
      maxFeePerGasM: float,
      maxFeePerGasH: float,
      l1GasFee: float,
      eip1559Enabled: bool,
  ) =
    self.QObject.setup
    self.gasPrice = gasPrice
    self.baseFee = baseFee
    self.maxPriorityFeePerGas = maxPriorityFeePerGas
    self.maxFeePerGasL = maxFeePerGasL
    self.maxFeePerGasM = maxFeePerGasM
    self.maxFeePerGasH = maxFeePerGasH
    self.l1GasFee = l1GasFee
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
      l1GasFee: float = 0,
      eip1559Enabled: bool = false,
  ): GasFeesItem =
    new(result, delete)
    result.setup(
      gasPrice, baseFee, maxPriorityFeePerGas, maxFeePerGasL, maxFeePerGasM,
      maxFeePerGasH, l1GasFee, eip1559Enabled,
    )

  proc `$`*(self: GasFeesItem): string =
    result = "GasFeesItem("
    result = result & "\ngasPrice: " & $self.gasPrice
    result = result & "\nbaseFee: " & $self.baseFee
    result = result & "\nmaxPriorityFeePerGas: " & $self.maxPriorityFeePerGas
    result = result & "\nmaxFeePerGasL: " & $self.maxFeePerGasL
    result = result & "\nmaxFeePerGasM: " & $self.maxFeePerGasM
    result = result & "\nmaxFeePerGasH: " & $self.maxFeePerGasH
    result = result & "\nl1GasFee: " & $self.l1GasFee
    result = result & "\neip1559Enabled: " & $self.eip1559Enabled
    result = result & ")"

  proc getGasPrice*(self: GasFeesItem): float {.slot.} =
    return self.gasPrice

  QtProperty[float] gasPrice:
    read = getGasPrice

  proc getBaseFee*(self: GasFeesItem): float {.slot.} =
    return self.baseFee

  QtProperty[float] baseFee:
    read = getBaseFee

  proc getMaxPriorityFeePerGas*(self: GasFeesItem): float {.slot.} =
    return self.maxPriorityFeePerGas

  QtProperty[float] maxPriorityFeePerGas:
    read = getMaxPriorityFeePerGas

  proc getMaxFeePerGasL*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasL

  QtProperty[float] maxFeePerGasL:
    read = getMaxFeePerGasL

  proc getMaxFeePerGasM*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasM

  QtProperty[float] maxFeePerGasM:
    read = getMaxFeePerGasM

  proc getMaxFeePerGasH*(self: GasFeesItem): float {.slot.} =
    return self.maxFeePerGasH

  QtProperty[float] maxFeePerGasH:
    read = getMaxFeePerGasH

  proc getL1GasFee*(self: GasFeesItem): float {.slot.} =
    return self.l1GasFee

  QtProperty[float] l1GasFee:
    read = getL1GasFee

  proc getEip1559Enabled*(self: GasFeesItem): bool {.slot.} =
    return self.eip1559Enabled

  QtProperty[bool] eip1559Enabled:
    read = getEip1559Enabled
