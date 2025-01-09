import NimQml

import app_service/common/wallet_constants
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
    txNonce: string
    txMaxFeesPerGas: string
    txBaseFee: string
    txPriorityFee: string
    txGasAmount: string
    txBonderFees: string
    txTokenFees: string
    txEstimatedTime: int
    txFee: string
    txL1Fee: string
    txTotalFee: string
    approvalRequired: bool
    approvalAmountRequired: string
    approvalContractAddress: string
    approvalTxNonce: string
    approvalMaxFeesPerGas: string
    approvalBaseFee: string
    approvalPriorityFee: string
    approvalGasAmount: string
    approvalEstimatedTime: int
    approvalFee: string
    approvalL1Fee: string

  proc setup*(
      self: PathItem,
      processorName: string,
      fromChain: int,
      toChain: int,
      fromToken: string,
      toToken: string,
      amountIn: string,
      amountInLocked: bool,
      amountOut: string,
      suggestedLevelsForMaxFeesPerGas: MaxFeeLevelsItem,
      txNonce: string,
      txMaxFeesPerGas: string,
      txBaseFee: string,
      txPriorityFee: string,
      txGasAmount: string,
      txBonderFees: string,
      txTokenFees: string,
      txEstimatedTime: int,
      txFee: string,
      txL1Fee: string,
      txTotalFee: string,
      approvalRequired: bool,
      approvalAmountRequired: string,
      approvalContractAddress: string,
      approvalTxNonce: string,
      approvalMaxFeesPerGas: string,
      approvalBaseFee: string,
      approvalPriorityFee: string,
      approvalGasAmount: string,
      approvalEstimatedTime: int,
      approvalFee: string,
      approvalL1Fee: string,
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
    self.txNonce = txNonce
    self.txMaxFeesPerGas = txMaxFeesPerGas
    self.txBaseFee = txBaseFee
    self.txPriorityFee = txPriorityFee
    self.txGasAmount = txGasAmount
    self.txBonderFees = txBonderFees
    self.txTokenFees = txTokenFees
    self.txEstimatedTime = txEstimatedTime
    self.txFee = txFee
    self.txL1Fee = txL1Fee
    self.txTotalFee = txTotalFee
    self.approvalRequired = approvalRequired
    self.approvalAmountRequired = approvalAmountRequired
    self.approvalContractAddress = approvalContractAddress
    self.approvalTxNonce = approvalTxNonce
    self.approvalMaxFeesPerGas = approvalMaxFeesPerGas
    self.approvalBaseFee = approvalBaseFee
    self.approvalPriorityFee = approvalPriorityFee
    self.approvalGasAmount = approvalGasAmount
    self.approvalEstimatedTime = approvalEstimatedTime
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
      txNonce: string,
      txMaxFeesPerGas: string,
      txBaseFee: string,
      txPriorityFee: string,
      txGasAmount: string,
      txBonderFees: string,
      txTokenFees: string,
      txEstimatedTime: int,
      txFee: string,
      txL1Fee: string,
      txTotalFee: string,
      approvalRequired: bool,
      approvalAmountRequired: string,
      approvalContractAddress: string,
      approvalTxNonce: string,
      approvalMaxFeesPerGas: string,
      approvalBaseFee: string,
      approvalPriorityFee: string,
      approvalGasAmount: string,
      approvalEstimatedTime: int,
      approvalFee: string,
      approvalL1Fee: string,
  ): PathItem =
    new(result, delete)
    result.setup(
      processorName, fromChain, toChain, fromToken, toToken, amountIn, amountInLocked,
      amountOut, suggestedLevelsForMaxFeesPerGas, txNonce, txMaxFeesPerGas, txBaseFee,
      txPriorityFee, txGasAmount, txBonderFees, txTokenFees, txEstimatedTime, txFee,
      txL1Fee, txTotalFee, approvalRequired, approvalAmountRequired,
      approvalContractAddress, approvalTxNonce, approvalMaxFeesPerGas, approvalBaseFee,
      approvalPriorityFee, approvalGasAmount, approvalEstimatedTime, approvalFee,
      approvalL1Fee,
    )

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
    result &=
      "\nsuggestedLevelsForMaxFeesPerGas: " & $self.suggestedLevelsForMaxFeesPerGas
    result &= "\ntxNonce: " & $self.txNonce
    result &= "\ntxMaxFeesPerGas: " & $self.txMaxFeesPerGas
    result &= "\ntxBaseFee: " & $self.txBaseFee
    result &= "\ntxPriorityFee: " & $self.txPriorityFee
    result &= "\ntxGasAmount: " & $self.txGasAmount
    result &= "\ntxBonderFees: " & $self.txBonderFees
    result &= "\ntxTokenFees: " & $self.txTokenFees
    result &= "\ntxEstimatedTime: " & $self.txEstimatedTime
    result &= "\ntxFee: " & $self.txFee
    result &= "\ntxL1Fee: " & $self.txL1Fee
    result &= "\ntxTotalFee: " & $self.txTotalFee
    result &= "\napprovalRequired: " & $self.approvalRequired
    result &= "\napprovalAmountRequired: " & $self.approvalAmountRequired
    result &= "\napprovalContractAddress: " & $self.approvalContractAddress
    result &= "\napprovalTxNonce: " & $self.approvalTxNonce
    result &= "\napprovalMaxFeesPerGas: " & $self.approvalMaxFeesPerGas
    result &= "\napprovalBaseFee: " & $self.approvalBaseFee
    result &= "\napprovalPriorityFee: " & $self.approvalPriorityFee
    result &= "\napprovalGasAmount: " & $self.approvalGasAmount
    result &= "\napprovalEstimatedTime: " & $self.approvalEstimatedTime
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

  proc txNonce*(self: PathItem): string =
    return self.txNonce

  proc txMaxFeesPerGas*(self: PathItem): string =
    return self.txMaxFeesPerGas

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

  proc txEstimatedTime*(self: PathItem): int =
    return self.txEstimatedTime

  proc txFee*(self: PathItem): string =
    return self.txFee

  proc txL1Fee*(self: PathItem): string =
    return self.txL1Fee

  proc txTotalFee*(self: PathItem): string =
    return self.txTotalFee

  proc approvalRequired*(self: PathItem): bool =
    return self.approvalRequired

  proc approvalAmountRequired*(self: PathItem): string =
    return self.approvalAmountRequired

  proc approvalContractAddress*(self: PathItem): string =
    return self.approvalContractAddress

  proc approvalTxNonce*(self: PathItem): string =
    return self.approvalTxNonce

  proc approvalMaxFeesPerGas*(self: PathItem): string =
    return self.approvalMaxFeesPerGas

  proc approvalBaseFee*(self: PathItem): string =
    return self.approvalBaseFee

  proc approvalPriorityFee*(self: PathItem): string =
    return self.approvalPriorityFee

  proc approvalGasAmount*(self: PathItem): string =
    return self.approvalGasAmount

  proc approvalEstimatedTime*(self: PathItem): int =
    return self.approvalEstimatedTime

  proc approvalFee*(self: PathItem): string =
    return self.approvalFee

  proc approvalL1Fee*(self: PathItem): string =
    return self.approvalL1Fee

  proc estimatedTime*(self: PathItem): int =
    if self.processorName == wallet_constants.PROCESSOR_NAME_SWAP_PARASWAP:
      return self.txEstimatedTime + self.approvalEstimatedTime
    if self.processorName == wallet_constants.PROCESSOR_NAME_BRIDGE_HOP:
      return self.txEstimatedTime + 1
    return self.txEstimatedTime
