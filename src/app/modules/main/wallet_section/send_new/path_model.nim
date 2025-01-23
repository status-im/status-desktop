import NimQml, Tables, strutils, stew/shims/strformat

import ./path_item

export path_item

type
  ModelRole {.pure.} = enum
    Index = UserRole + 1,
    ProcessorName,
    FromChain,
    ToChain,
    FromToken,
    ToToken,
    AmountIn,
    AmountInLocked,
    AmountOut,
    SuggestedMaxFeesPerGasLowLevel,
    SuggestedPriorityFeePerGasLowLevel,
    SuggestedMaxFeesPerGasMediumLevel,
    SuggestedPriorityFeePerGasMediumLevel,
    SuggestedMaxFeesPerGasHighLevel,
    SuggestedPriorityFeePerGasHighLevel,
    SuggestedMinPriorityFee,
    SuggestedMaxPriorityFee,
    CurrentBaseFee,
    SuggestedTxNonce,
    SuggestedTxGasAmount,
    SuggestedApprovalTxNonce,
    SuggestedApprovalGasAmount,
    TxNonce,
    TxGasFeeMode,
    TxMaxFeesPerGas,
    TxBaseFee,
    TxPriorityFee,
    TxGasAmount,
    TxBonderFees,
    TxTokenFees,
    TxEstimatedTime,
    TxFee,
    TxL1Fee,
    TxTotalFee,
    ApprovalRequired,
    ApprovalAmountRequired,
    ApprovalContractAddress,
    ApprovalTxNonce,
    ApprovalGasFeeMode,
    ApprovalMaxFeesPerGas,
    ApprovalBaseFee,
    ApprovalPriorityFee,
    ApprovalGasAmount,
    ApprovalEstimatedTime,
    ApprovalFee,
    ApprovalL1Fee,
    EstimatedTime

QtObject:
  type
    PathModel* = ref object of QAbstractListModel
      items*: seq[PathItem]

  proc delete(self: PathModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: PathModel) =
    self.QAbstractListModel.setup

  proc newPathModel*(): PathModel =
    new(result, delete)
    result.setup

  proc `$`*(self: PathModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""[{i}]:({$self.items[i]})"""

  method rowCount(self: PathModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: PathModel): Table[int, string] =
    {
      ModelRole.Index.int: "index",
      ModelRole.ProcessorName.int: "processorName",
      ModelRole.FromChain.int: "fromChain",
      ModelRole.ToChain.int: "toChain",
      ModelRole.FromToken.int: "fromToken",
      ModelRole.ToToken.int: "toToken",
      ModelRole.AmountIn.int: "amountIn",
      ModelRole.AmountInLocked.int: "amountInLocked",
      ModelRole.AmountOut.int: "amountOut",
      ModelRole.SuggestedMaxFeesPerGasLowLevel.int: "suggestedMaxFeesPerGasLowLevel",
      ModelRole.SuggestedPriorityFeePerGasLowLevel.int: "suggestedPriorityFeePerGasLowLevel",
      ModelRole.SuggestedMaxFeesPerGasMediumLevel.int: "suggestedMaxFeesPerGasMediumLevel",
      ModelRole.SuggestedPriorityFeePerGasMediumLevel.int: "suggestedPriorityFeePerGasMediumLevel",
      ModelRole.SuggestedMaxFeesPerGasHighLevel.int: "suggestedMaxFeesPerGasHighLevel",
      ModelRole.SuggestedPriorityFeePerGasHighLevel.int: "suggestedPriorityFeePerGasHighLevel",
      ModelRole.SuggestedMinPriorityFee.int: "suggestedMinPriorityFee",
      ModelRole.SuggestedMaxPriorityFee.int: "suggestedMaxPriorityFee",
      ModelRole.CurrentBaseFee.int: "currentBaseFee",
      ModelRole.SuggestedTxNonce.int: "suggestedTxNonce",
      ModelRole.SuggestedTxGasAmount.int: "suggestedTxGasAmount",
      ModelRole.SuggestedApprovalTxNonce.int: "suggestedApprovalTxNonce",
      ModelRole.SuggestedApprovalGasAmount.int: "suggestedApprovalGasAmount",
      ModelRole.TxNonce.int: "txNonce",
      ModelRole.TxGasFeeMode.int: "txGasFeeMode",
      ModelRole.TxMaxFeesPerGas.int: "txMaxFeesPerGas",
      ModelRole.TxBaseFee.int: "txBaseFee",
      ModelRole.TxPriorityFee.int: "txPriorityFee",
      ModelRole.TxGasAmount.int: "txGasAmount",
      ModelRole.TxBonderFees.int: "txBonderFees",
      ModelRole.TxTokenFees.int: "txTokenFees",
      ModelRole.TxEstimatedTime.int: "txEstimatedTime",
      ModelRole.TxFee.int: "txFee",
      ModelRole.TxL1Fee.int: "txL1Fee",
      ModelRole.TxTotalFee.int: "txTotalFee",
      ModelRole.ApprovalRequired.int: "approvalRequired",
      ModelRole.ApprovalAmountRequired.int: "approvalAmountRequired",
      ModelRole.ApprovalContractAddress.int: "approvalContractAddress",
      ModelRole.ApprovalTxNonce.int: "approvalTxNonce",
      ModelRole.ApprovalGasFeeMode.int: "approvalGasFeeMode",
      ModelRole.ApprovalMaxFeesPerGas.int: "approvalMaxFeesPerGas",
      ModelRole.ApprovalBaseFee.int: "approvalBaseFee",
      ModelRole.ApprovalPriorityFee.int: "approvalPriorityFee",
      ModelRole.ApprovalGasAmount.int: "approvalGasAmount",
      ModelRole.ApprovalEstimatedTime.int: "approvalEstimatedTime",
      ModelRole.ApprovalFee.int: "approvalFee",
      ModelRole.ApprovalL1Fee.int: "approvalL1Fee",
      ModelRole.EstimatedTime.int: "estimatedTime"
    }.toTable

  proc setItems*(self: PathModel, items: seq[PathItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  method data(self: PathModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Index:
      result = newQVariant(index.row)
    of ModelRole.ProcessorName:
      result = newQVariant(item.processorName)
    of ModelRole.FromChain:
      result = newQVariant(item.fromChain)
    of ModelRole.ToChain:
      result = newQVariant(item.toChain)
    of ModelRole.FromToken:
      result = newQVariant(item.fromToken)
    of ModelRole.ToToken:
      result = newQVariant(item.toToken)
    of ModelRole.AmountIn:
      result = newQVariant(item.amountIn)
    of ModelRole.AmountInLocked:
      result = newQVariant(item.amountInLocked)
    of ModelRole.AmountOut:
      result = newQVariant(item.amountOut)
    of ModelRole.SuggestedMaxFeesPerGasLowLevel:
      result = newQVariant(item.suggestedMaxFeesPerGasLowLevel)
    of ModelRole.SuggestedPriorityFeePerGasLowLevel:
      result = newQVariant(item.suggestedPriorityFeePerGasLowLevel)
    of ModelRole.SuggestedMaxFeesPerGasMediumLevel:
      result = newQVariant(item.suggestedMaxFeesPerGasMediumLevel)
    of ModelRole.SuggestedPriorityFeePerGasMediumLevel:
      result = newQVariant(item.suggestedPriorityFeePerGasMediumLevel)
    of ModelRole.SuggestedMaxFeesPerGasHighLevel:
      result = newQVariant(item.suggestedMaxFeesPerGasHighLevel)
    of ModelRole.SuggestedPriorityFeePerGasHighLevel:
      result = newQVariant(item.suggestedPriorityFeePerGasHighLevel)
    of ModelRole.SuggestedMinPriorityFee:
      result = newQVariant(item.suggestedMinPriorityFee)
    of ModelRole.SuggestedMaxPriorityFee:
      result = newQVariant(item.suggestedMaxPriorityFee)
    of ModelRole.CurrentBaseFee:
      result = newQVariant(item.currentBaseFee)
    of ModelRole.SuggestedTxNonce:
      result = newQVariant(item.suggestedTxNonce)
    of ModelRole.SuggestedTxGasAmount:
      result = newQVariant(item.suggestedTxGasAmount)
    of ModelRole.SuggestedApprovalTxNonce:
      result = newQVariant(item.suggestedApprovalTxNonce)
    of ModelRole.SuggestedApprovalGasAmount:
      result = newQVariant(item.suggestedApprovalGasAmount)
    of ModelRole.TxNonce:
      result = newQVariant(item.txNonce)
    of ModelRole.TxGasFeeMode:
      result = newQVariant(item.txGasFeeMode)
    of ModelRole.TxMaxFeesPerGas:
      result = newQVariant(item.txMaxFeesPerGas)
    of ModelRole.TxBaseFee:
      result = newQVariant(item.txBaseFee)
    of ModelRole.TxPriorityFee:
      result = newQVariant(item.txPriorityFee)
    of ModelRole.TxGasAmount:
      result = newQVariant(item.txGasAmount)
    of ModelRole.TxBonderFees:
      result = newQVariant(item.txBonderFees)
    of ModelRole.TxTokenFees:
      result = newQVariant(item.txTokenFees)
    of ModelRole.TxEstimatedTime:
      result = newQVariant(item.txEstimatedTime)
    of ModelRole.TxFee:
      result = newQVariant(item.txFee)
    of ModelRole.TxL1Fee:
      result = newQVariant(item.txL1Fee)
    of ModelRole.TxTotalFee:
      result = newQVariant(item.txTotalFee)
    of ModelRole.ApprovalRequired:
      result = newQVariant(item.approvalRequired)
    of ModelRole.ApprovalAmountRequired:
      result = newQVariant(item.approvalAmountRequired)
    of ModelRole.ApprovalContractAddress:
      result = newQVariant(item.approvalContractAddress)
    of ModelRole.ApprovalTxNonce:
      result = newQVariant(item.approvalTxNonce)
    of ModelRole.ApprovalGasFeeMode:
      result = newQVariant(item.approvalGasFeeMode)
    of ModelRole.ApprovalMaxFeesPerGas:
      result = newQVariant(item.approvalMaxFeesPerGas)
    of ModelRole.ApprovalBaseFee:
      result = newQVariant(item.approvalBaseFee)
    of ModelRole.ApprovalPriorityFee:
      result = newQVariant(item.approvalPriorityFee)
    of ModelRole.ApprovalGasAmount:
      result = newQVariant(item.approvalGasAmount)
    of ModelRole.ApprovalEstimatedTime:
      result = newQVariant(item.approvalEstimatedTime)
    of ModelRole.ApprovalFee:
      result = newQVariant(item.approvalFee)
    of ModelRole.ApprovalL1Fee:
      result = newQVariant(item.approvalL1Fee)
    of ModelRole.EstimatedTime:
      result = newQVariant(item.estimatedTime)
    else:
      discard
