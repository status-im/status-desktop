# import json, json_serialization, stint

# import ../network/dto, ../token/dto

# include  app_service/common/json_utils

import json, strutils, stint, json_serialization
import sequtils, sugar

import
  web3/ethtypes

include  ../../common/json_utils
import ../network/dto, ../token/dto

type
  SuggestedLevelsForMaxFeesPerGasDto* = ref object
    low*: UInt256
    medium*: UInt256
    high*: UInt256

type
  TransactionPathDtoV2* = ref object
    routerInputParamsUuid*: string
    processorName*: string
    fromChain*: NetworkDto
    toChain*: NetworkDto
    fromToken*: TokenDto
    toToken*: TokenDto
    amountIn*: UInt256
    amountInLocked*: bool
    amountOut*: UInt256

    suggestedLevelsForMaxFeesPerGas*: SuggestedLevelsForMaxFeesPerGasDto

    txNonce*: UInt256
    txMaxFeesPerGas*: UInt256
    txBaseFee*: UInt256
    txPriorityFee*: UInt256
    txGasAmount*: uint64
    txBonderFees*: UInt256
    txTokenFees*: UInt256
    txEstimatedTime*: int

    txFee*: UInt256
    txL1Fee*: UInt256

    approvalRequired*: bool
    approvalAmountRequired*: UInt256
    approvalContractAddress*: string
    approvalTxNonce*: UInt256
    approvalMaxFeesPerGas*: UInt256
    approvalBaseFee*: UInt256
    approvalPriorityFee*: UInt256
    approvalGasAmount*: uint64
    approvalEstimatedTime*: int

    approvalFee*: UInt256
    approvalL1Fee*: UInt256

    txTotalFee*: UInt256

proc toSuggestedLevelsForMaxFeesPerGasDto*(jsonObj: JsonNode): SuggestedLevelsForMaxFeesPerGasDto =
  result = SuggestedLevelsForMaxFeesPerGasDto()
  var value: string
  if jsonObj.getProp("low", value):
    result.low = stint.fromHex(UInt256, $value)
  if jsonObj.getProp("medium", value):
    result.medium = stint.fromHex(UInt256, $value)
  if jsonObj.getProp("high", value):
    result.high = stint.fromHex(UInt256, $value)

proc toTransactionPathDtoV2*(jsonObj: JsonNode): TransactionPathDtoV2 =
  result = TransactionPathDtoV2()
  discard jsonObj.getProp("RouterInputParamsUuid", result.routerInputParamsUuid)
  discard jsonObj.getProp("ProcessorName", result.processorName)
  result.fromChain = Json.decode($jsonObj["FromChain"], NetworkDto, allowUnknownFields = true)
  result.toChain = Json.decode($jsonObj["ToChain"], NetworkDto, allowUnknownFields = true)
  result.fromToken = Json.decode($jsonObj["FromToken"], TokenDto, allowUnknownFields = true)
  result.toToken = Json.decode($jsonObj["ToToken"], TokenDto, allowUnknownFields = true)
  result.amountIn = stint.fromHex(UInt256, jsonObj{"AmountIn"}.getStr)
  discard jsonObj.getProp("AmountInLocked", result.amountInLocked)
  result.amountOut = stint.fromHex(UInt256, jsonObj{"AmountOut"}.getStr)
  result.suggestedLevelsForMaxFeesPerGas = jsonObj["SuggestedLevelsForMaxFeesPerGas"].toSuggestedLevelsForMaxFeesPerGasDto()
  result.txNonce = stint.fromHex(UInt256, jsonObj{"TxNonce"}.getStr)
  result.txMaxFeesPerGas = stint.fromHex(UInt256, jsonObj{"TxMaxFeesPerGas"}.getStr)
  result.txBaseFee = stint.fromHex(UInt256, jsonObj{"TxBaseFee"}.getStr)
  result.txPriorityFee = stint.fromHex(UInt256, jsonObj{"TxPriorityFee"}.getStr)
  discard jsonObj.getProp("TxGasAmount", result.txGasAmount)
  result.txBonderFees = stint.fromHex(UInt256, jsonObj{"TxBonderFees"}.getStr)
  result.txTokenFees = stint.fromHex(UInt256, jsonObj{"TxTokenFees"}.getStr)
  discard jsonObj.getProp("TxEstimatedTime", result.txEstimatedTime)
  result.txFee = stint.fromHex(UInt256, jsonObj{"TxFee"}.getStr)
  result.txL1Fee = stint.fromHex(UInt256, jsonObj{"TxL1Fee"}.getStr)
  discard jsonObj.getProp("ApprovalRequired", result.approvalRequired)
  result.approvalAmountRequired = stint.fromHex(UInt256, jsonObj{"ApprovalAmountRequired"}.getStr)
  discard jsonObj.getProp("ApprovalContractAddress", result.approvalContractAddress)
  result.approvalTxNonce = stint.fromHex(UInt256, jsonObj{"ApprovalTxNonce"}.getStr)
  result.approvalMaxFeesPerGas = stint.fromHex(UInt256, jsonObj{"ApprovalMaxFeesPerGas"}.getStr)
  result.approvalBaseFee = stint.fromHex(UInt256, jsonObj{"ApprovalBaseFee"}.getStr)
  result.approvalPriorityFee = stint.fromHex(UInt256, jsonObj{"ApprovalPriorityFee"}.getStr)
  discard jsonObj.getProp("ApprovalGasAmount", result.approvalGasAmount)
  discard jsonObj.getProp("ApprovalEstimatedTime", result.approvalEstimatedTime)
  result.approvalFee = stint.fromHex(UInt256, jsonObj{"ApprovalFee"}.getStr)
  result.approvalL1Fee = stint.fromHex(UInt256, jsonObj{"ApprovalL1Fee"}.getStr)
  result.txTotalFee = stint.fromHex(UInt256, jsonObj{"TxTotalFee"}.getStr)

proc toTransactionPathsDtoV2*(jsonObj: JsonNode): seq[TransactionPathDtoV2] =
  return jsonObj.getElems().map(x => x.toTransactionPathDtoV2())

proc toTransactionPathsDtoV2*(rawPaths: string): seq[TransactionPathDtoV2] =
  return rawPaths.parseJson.toTransactionPathsDtoV2()
