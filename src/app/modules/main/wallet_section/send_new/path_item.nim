import NimQml

import ./max_fee_levels_item

QtObject:
  type PathItem* = ref object of QObject
    processorName: string
    fromChain: int
    toChain: int
    fromToken: string
    toToken: string
    amountIn: string
    amountInLocked: bool
    amountOut: string
    suggestedLevelsForMaxFeesPerGas: MaxFeeLevelsItem
    maxFeesPerGas: string
    txBaseFee: string
    txPriorityFee: string
    txGasAmount: string
    txBonderFees: string
    txTokenFees: string
    txFee: string
    txL1Fee: string
    txTotalFee: string
    estimatedTime: int
    approvalRequired: bool
    approvalAmountRequired : string
    approvalContractAddress: string
    approvalBaseFee: string
    approvalPriorityFee: string
    approvalGasAmount: string
    approvalFee: string
    approvalL1Fee: string

  proc setup*(self: PathItem,
    processorName: string,
    fromChain: int,
    toChain: int,
    fromToken: string,
    toToken: string,
    amountIn: string,
    amountInLocked: bool,
    amountOut: string,
    suggestedLevelsForMaxFeesPerGas: MaxFeeLevelsItem,
    maxFeesPerGas: string,
    txBaseFee: string,
    txPriorityFee: string,
    txGasAmount: string,
    txBonderFees: string,
    txTokenFees: string,
    txFee: string,
    txL1Fee: string,
    txTotalFee: string,
    estimatedTime: int,
    approvalRequired: bool,
    approvalAmountRequired: string,
    approvalContractAddress: string,
    approvalBaseFee: string,
    approvalPriorityFee: string,
    approvalGasAmount: string,
    approvalFee: string,
    approvalL1Fee: string
  ) =
    self.QObject.setup
    self.processorName = processorName
    self.fromChain = fromChain
    self.toChain = toChain
    self.fromToken = fromToken
    self.toToken = toToken
    self.amountIn = amountIn
    self.amountInLocked = amountInLocked
    self.amountOut = amountOut
    self.suggestedLevelsForMaxFeesPerGas = suggestedLevelsForMaxFeesPerGas
    self.maxFeesPerGas = maxFeesPerGas
    self.txBaseFee = txBaseFee
    self.txPriorityFee = txPriorityFee
    self.txGasAmount = txGasAmount
    self.txBonderFees = txBonderFees
    self.txTokenFees = txTokenFees
    self.txFee = txFee
    self.txL1Fee = txL1Fee
    self.txTotalFee = txTotalFee
    self.estimatedTime = estimatedTime
    self.approvalRequired = approvalRequired
    self.approvalAmountRequired = approvalAmountRequired
    self.approvalContractAddress = approvalContractAddress
    self.approvalBaseFee = approvalBaseFee
    self.approvalPriorityFee = approvalPriorityFee
    self.approvalGasAmount = approvalGasAmount
    self.approvalFee = approvalFee
    self.approvalL1Fee = approvalL1Fee

  proc delete*(self: PathItem) =
    self.QObject.delete

  proc newPathItem*(
    processorName: string,
    fromChain: int,
    toChain: int,
    fromToken: string,
    toToken: string,
    amountIn: string,
    amountInLocked: bool,
    amountOut: string,
    suggestedLevelsForMaxFeesPerGas: MaxFeeLevelsItem,
    maxFeesPerGas: string,
    txBaseFee: string,
    txPriorityFee: string,
    txGasAmount: string,
    txBonderFees: string,
    txTokenFees: string,
    txFee: string,
    txL1Fee: string,
    txTotalFee: string,
    estimatedTime: int,
    approvalRequired: bool,
    approvalAmountRequired: string,
    approvalContractAddress: string,
    approvalBaseFee: string,
    approvalPriorityFee: string,
    approvalGasAmount: string,
    approvalFee: string,
    approvalL1Fee: string
  ): PathItem =
    new(result, delete)
    result.setup(processorName, fromChain, toChain, fromToken, toToken,
      amountIn, amountInLocked, amountOut, suggestedLevelsForMaxFeesPerGas,
      maxFeesPerGas, txBaseFee,txPriorityFee, txGasAmount, txBonderFees,
      txTokenFees, txFee, txL1Fee, txTotalFee, estimatedTime, approvalRequired,
      approvalAmountRequired, approvalContractAddress, approvalBaseFee,
      approvalPriorityFee, approvalGasAmount, approvalFee, approvalL1Fee)

  proc `$`*(self: PathItem): string =
    result = "PathItem("
    result &= "\nprocessorName: " & $self.processorName
    result &= "\nfromChain: " & $self.fromChain
    result &= "\ntoChain: " & $self.toChain
    result &= "\nfromToken: " & $self.fromToken
    result &= "\ntoToken: " & $self.toToken
    result &= "\namountIn: " & $self.amountIn
    result &= "\namountInLocked: " & $self.amountInLocked
    result &= "\namountOut: " & $self.amountOut
    result &= "\nsuggestedLevelsForMaxFeesPerGas: " & $self.suggestedLevelsForMaxFeesPerGas
    result &= "\nmaxFeesPerGas: " & $self.maxFeesPerGas
    result &= "\ntxBaseFee: " & $self.txBaseFee
    result &= "\ntxPriorityFee: " & $self.txPriorityFee
    result &= "\ntxGasAmount: " & $self.txGasAmount
    result &= "\ntxBonderFees: " & $self.txBonderFees
    result &= "\ntxTokenFees: " & $self.txTokenFees
    result &= "\ntxFee: " & $self.txFee
    result &= "\ntxL1Fee: " & $self.txL1Fee
    result &= "\ntxTotalFee: " & $self.txTotalFee
    result &= "\nestimatedTime: " & $self.estimatedTime
    result &= "\napprovalRequired: " & $self.approvalRequired
    result &= "\napprovalAmountRequired: " & $self.approvalAmountRequired
    result &= "\napprovalContractAddress: " & $self.approvalContractAddress
    result &= "\napprovalBaseFee: " & $self.approvalBaseFee
    result &= "\napprovalPriorityFee: " & $self.approvalPriorityFee
    result &= "\napprovalGasAmount: " & $self.approvalGasAmount
    result &= "\napprovalFee: " & $self.approvalFee
    result &= "\napprovalL1Fee: " & $self.approvalL1Fee
    result &= ")"

  proc processorName*(self: PathItem): string =
    return self.processorName

  proc fromChain*(self: PathItem): int =
    return self.fromChain

  proc toChain*(self: PathItem): int =
    return self.toChain

  proc fromToken*(self: PathItem): string =
    return self.fromToken

  proc toToken*(self: PathItem): string =
    return self.toToken

  proc amountIn*(self: PathItem): string =
    return self.amountIn

  proc amountInLocked*(self: PathItem): bool =
    return self.amountInLocked

  proc amountOut*(self: PathItem): string =
    return self.amountOut

  proc suggestedLevelsForMaxFeesPerGas*(self: PathItem): MaxFeeLevelsItem =
    return self.suggestedLevelsForMaxFeesPerGas

  proc maxFeesPerGas*(self: PathItem): string =
    return self.maxFeesPerGas

  proc txBaseFee*(self: PathItem): string =
    return self.txBaseFee

  proc txPriorityFee*(self: PathItem): string =
    return self.txPriorityFee

  proc txGasAmount*(self: PathItem): string =
    return self.txGasAmount

  proc txBonderFees*(self: PathItem): string =
    return self.txBonderFees

  proc txTokenFees*(self: PathItem): string =
    return self.txTokenFees

  proc txFee*(self: PathItem): string =
    return self.txFee

  proc txL1Fee*(self: PathItem): string =
    return self.txL1Fee

  proc txTotalFee*(self: PathItem): string =
    return self.txTotalFee

  proc estimatedTime*(self: PathItem): int =
    return self.estimatedTime

  proc approvalRequired*(self: PathItem): bool =
    return self.approvalRequired

  proc approvalAmountRequired*(self: PathItem): string =
    return self.approvalAmountRequired

  proc approvalContractAddress*(self: PathItem): string =
    return self.approvalContractAddress

  proc approvalBaseFee*(self: PathItem): string =
    return self.approvalBaseFee

  proc approvalPriorityFee*(self: PathItem): string =
    return self.approvalPriorityFee

  proc approvalGasAmount*(self: PathItem): string =
    return self.approvalGasAmount

  proc approvalFee*(self: PathItem): string =
    return self.approvalFee

  proc approvalL1Fee*(self: PathItem): string =
    return self.approvalL1Fee
