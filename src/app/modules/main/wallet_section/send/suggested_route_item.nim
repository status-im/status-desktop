import NimQml

import ./gas_fees_item

QtObject:
  type SuggestedRouteItem* = ref object of QObject
    bridgeName: string
    fromNetwork: int
    toNetwork: int
    maxAmountIn: string
    amountIn: string
    amountOut: string
    gasAmount: string
    gasFees: GasFeesItem
    tokenFees: float
    cost: float
    estimatedTime: int
    amountInLocked: bool
    isFirstSimpleTx: bool
    isFirstBridgeTx: bool
    approvalRequired: bool
    approvalGasFees: float

  proc setup*(self: SuggestedRouteItem,
    bridgeName: string,
    fromNetwork: int,
    toNetwork: int,
    maxAmountIn: string,
    amountIn: string,
    amountOut: string,
    gasAmount: string,
    gasFees: GasFeesItem,
    tokenFees: float,
    cost: float,
    estimatedTime: int,
    amountInLocked: bool,
    isFirstSimpleTx: bool,
    isFirstBridgeTx: bool,
    approvalRequired: bool,
    approvalGasFees: float
  ) =
    self.QObject.setup
    self.bridgeName = bridgeName
    self.fromNetwork = fromNetwork
    self.toNetwork = toNetwork
    self.maxAmountIn = maxAmountIn
    self.amountIn = amountIn
    self.amountOut = amountOut
    self.gasAmount = gasAmount
    self.gasFees = gasFees
    self.tokenFees = tokenFees
    self.cost = cost
    self.estimatedTime = estimatedTime
    self.amountInLocked = amountInLocked
    self.isFirstSimpleTx = isFirstSimpleTx
    self.isFirstBridgeTx = isFirstBridgeTx
    self.approvalRequired = approvalRequired
    self.approvalGasFees = approvalGasFees

  proc delete*(self: SuggestedRouteItem) =
      self.QObject.delete

  proc newSuggestedRouteItem*(
    bridgeName: string = "",
    fromNetwork: int = 0,
    toNetwork: int = 0,
    maxAmountIn: string = "",
    amountIn: string = "",
    amountOut: string = "",
    gasAmount: string = "",
    gasFees: GasFeesItem = newGasFeesItem(),
    tokenFees: float = 0,
    cost: float = 0,
    estimatedTime: int = 0,
    amountInLocked: bool = false,
    isFirstSimpleTx: bool = false,
    isFirstBridgeTx: bool = false,
    approvalRequired: bool = false,
    approvalGasFees: float = 0
    ): SuggestedRouteItem =
      new(result, delete)
      result.setup(bridgeName, fromNetwork, toNetwork, maxAmountIn, amountIn, amountOut, gasAmount, gasFees, tokenFees,
        cost, estimatedTime, amountInLocked, isFirstSimpleTx, isFirstBridgeTx, approvalRequired, approvalGasFees)

  proc `$`*(self: SuggestedRouteItem): string =
    result = "SuggestedRouteItem("
    result = result & "\nbridgeName: " & $self.bridgeName
    result = result & "\nfromNetwork: " & $self.fromNetwork
    result = result & "\ntoNetwork: " & $self.toNetwork
    result = result & "\nmaxAmountIn: " & $self.maxAmountIn
    result = result & "\namountIn: " & $self.amountIn
    result = result & "\namountOut: " & $self.amountOut
    result = result & "\ngasAmount: " & $self.gasAmount
    result = result & "\ngasFees: " & $self.gasFees
    result = result & "\ntokenFees: " & $self.tokenFees
    result = result & "\ncost: " & $self.cost
    result = result & "\nestimatedTime: " & $self.estimatedTime
    result = result & "\namountInLocked: " & $self.amountInLocked
    result = result & "\nisFirstSimpleTx: " & $self.isFirstSimpleTx
    result = result & "\nisFirstBridgeTx: " & $self.isFirstBridgeTx
    result = result & "\napprovalRequired: " & $self.approvalRequired
    result = result & "\napprovalGasFees: " & $self.approvalGasFees
    result = result & ")"

  proc bridgeNameChanged*(self: SuggestedRouteItem) {.signal.}
  proc getBridgeName*(self: SuggestedRouteItem): string {.slot.} =
    return self.bridgeName
  QtProperty[string] bridgeName:
    read = getBridgeName
    notify = bridgeNameChanged

  proc fromNetworkChanged*(self: SuggestedRouteItem) {.signal.}
  proc getfromNetwork*(self: SuggestedRouteItem): int {.slot.} =
    return self.fromNetwork
  QtProperty[int] fromNetwork:
    read = getfromNetwork
    notify = fromNetworkChanged

  proc toNetworkChanged*(self: SuggestedRouteItem) {.signal.}
  proc getToNetwork*(self: SuggestedRouteItem): int {.slot.} =
    return self.toNetwork
  QtProperty[int] toNetwork:
    read = getToNetwork
    notify = toNetworkChanged

  proc maxAmountInChanged*(self: SuggestedRouteItem) {.signal.}
  proc getMaxAmountIn*(self: SuggestedRouteItem): string {.slot.} =
    return self.maxAmountIn
  QtProperty[string] maxAmountIn:
    read = getMaxAmountIn
    notify = maxAmountInChanged

  proc amountInChanged*(self: SuggestedRouteItem) {.signal.}
  proc getAmountIn*(self: SuggestedRouteItem): string {.slot.} =
    return self.amountIn
  QtProperty[string] amountIn:
    read = getAmountIn
    notify = amountInChanged

  proc amountOutChanged*(self: SuggestedRouteItem) {.signal.}
  proc getAmountOut*(self: SuggestedRouteItem): string {.slot.} =
    return self.amountOut
  QtProperty[string] amountOut:
    read = getAmountOut
    notify = amountOutChanged

  proc gasAmountChanged*(self: SuggestedRouteItem) {.signal.}
  proc getGasAmount*(self: SuggestedRouteItem): string {.slot.} =
    return self.gasAmount
  QtProperty[string] gasAmount:
    read = getGasAmount
    notify = gasAmountChanged

  proc gasFeesChanged*(self: SuggestedRouteItem) {.signal.}
  proc getGasFees*(self: SuggestedRouteItem): QVariant {.slot.} =
    return newQVariant(self.gasFees)
  QtProperty[QVariant] gasFees:
    read = getGasFees
    notify = gasFeesChanged

  proc tokenFeesChanged*(self: SuggestedRouteItem) {.signal.}
  proc getTokenFees*(self: SuggestedRouteItem): float {.slot.} =
    return self.tokenFees
  QtProperty[float] tokenFees:
    read = getTokenFees
    notify = tokenFeesChanged

  proc costChanged*(self: SuggestedRouteItem) {.signal.}
  proc getCost*(self: SuggestedRouteItem): float {.slot.} =
    return self.cost
  QtProperty[float] cost:
    read = getCost
    notify = costChanged

  proc estimatedTimeChanged*(self: SuggestedRouteItem) {.signal.}
  proc getEstimatedTime*(self: SuggestedRouteItem): int {.slot.} =
    return self.estimatedTime
  QtProperty[int] estimatedTime:
    read = getEstimatedTime
    notify = estimatedTimeChanged

  proc amountInLockedChanged*(self: SuggestedRouteItem) {.signal.}
  proc getAmountInLocked*(self: SuggestedRouteItem): bool {.slot.} =
    return self.amountInLocked
  QtProperty[bool] amountInLocked:
    read = getAmountInLocked
    notify = amountInLockedChanged

  proc isFirstSimpleTxChanged*(self: SuggestedRouteItem) {.signal.}
  proc getIsFirstSimpleTx*(self: SuggestedRouteItem): bool {.slot.} =
    return self.isFirstSimpleTx
  QtProperty[bool] isFirstSimpleTx:
    read = getIsFirstSimpleTx
    notify = isFirstSimpleTxChanged

  proc isFirstBridgeTxChanged*(self: SuggestedRouteItem) {.signal.}
  proc getIsFirstBridgeTx*(self: SuggestedRouteItem): bool {.slot.} =
    return self.isFirstBridgeTx
  QtProperty[bool] isFirstBridgeTx:
    read = getIsFirstBridgeTx
    notify = isFirstBridgeTxChanged

  proc approvalRequiredChanged*(self: SuggestedRouteItem) {.signal.}
  proc getApprovalRequired*(self: SuggestedRouteItem): bool {.slot.} =
    return self.approvalRequired
  QtProperty[bool] approvalRequired:
    read = getApprovalRequired
    notify = approvalRequiredChanged

  proc approvalGasFeesChanged*(self: SuggestedRouteItem) {.signal.}
  proc getApprovalGasFees*(self: SuggestedRouteItem): float {.slot.} =
    return self.approvalGasFees
  QtProperty[float] approvalGasFees:
    read = getApprovalGasFees
    notify = approvalGasFeesChanged
