import json, strutils, stint, json_serialization, strformat

import
  web3/ethtypes

include  ../../common/json_utils
import ../network/dto
import ../../common/conversion as service_conversion

import ./backend/transactions

type
  PendingTransactionTypeDto* {.pure.} = enum
    RegisterENS = "RegisterENS",
    SetPubKey = "SetPubKey",
    ReleaseENS = "ReleaseENS",
    BuyStickerPack = "BuyStickerPack"
    WalletTransfer = "WalletTransfer"
    DeployCommunityToken = "DeployCommunityToken"
    AirdropCommunityToken = "AirdropCommunityToken"
    RemoteDestructCollectible = "RemoteDestructCollectible"
    BurnCommunityToken = "BurnCommunityToken"

proc event*(self:PendingTransactionTypeDto):string =
  result = "transaction:" & $self

type
  TransactionDto* = ref object of RootObj
    id*: string
    typeValue*: string
    address*: string
    blockNumber*: string
    blockHash*: string
    contract*: string
    timestamp*: UInt256
    gasPrice*: string
    gasLimit*: string
    gasUsed*: string
    nonce*: string
    txStatus*: string
    value*: string
    tokenId*: UInt256
    fromAddress*: string
    to*: string
    chainId*: int
    maxFeePerGas*: string
    maxPriorityFeePerGas*: string
    input*: string
    txHash*: string
    multiTransactionID*: int
    baseGasFees*: string
    totalFees*: string
    maxTotalFees*: string
    additionalData*: string
    symbol*: string

proc getTotalFees(tip: string, baseFee: string, gasUsed: string, maxFee: string): string =
    var maxFees = stint.fromHex(Uint256, maxFee)
    var totalGasUsed = stint.fromHex(Uint256, tip) + stint.fromHex(Uint256, baseFee)
    if totalGasUsed >  maxFees:
      totalGasUsed = maxFees
    var totalGasUsedInHex = (totalGasUsed * stint.fromHex(Uint256, gasUsed)).toHex
    return totalGasUsedInHex

proc getMaxTotalFees(maxFee: string, gasLimit: string): string =
    return (stint.fromHex(Uint256, maxFee) * stint.fromHex(Uint256, gasLimit)).toHex

proc toTransactionDto*(jsonObj: JsonNode): TransactionDto =
  result = TransactionDto()
  result.timestamp = stint.fromHex(UInt256, jsonObj{"timestamp"}.getStr)
  result.tokenId = stint.fromHex(UInt256, jsonObj{"tokenId"}.getStr)
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("type", result.typeValue)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("contract", result.contract)
  discard jsonObj.getProp("blockNumber", result.blockNumber)
  discard jsonObj.getProp("blockHash", result.blockHash)
  discard jsonObj.getProp("gasPrice", result.gasPrice)
  discard jsonObj.getProp("gasLimit", result.gasLimit)
  discard jsonObj.getProp("gasUsed", result.gasUsed)
  discard jsonObj.getProp("nonce", result.nonce)
  discard jsonObj.getProp("txStatus", result.txStatus)
  discard jsonObj.getProp("value", result.value)
  discard jsonObj.getProp("from", result.fromAddress)
  discard jsonObj.getProp("to", result.to)
  discard jsonObj.getProp("networkId", result.chainId)
  discard jsonObj.getProp("maxFeePerGas", result.maxFeePerGas)
  discard jsonObj.getProp("maxPriorityFeePerGas", result.maxPriorityFeePerGas)
  discard jsonObj.getProp("input", result.input)
  discard jsonObj.getProp("txHash", result.txHash)
  discard jsonObj.getProp("multiTransactionID", result.multiTransactionID)
  discard jsonObj.getProp("base_gas_fee", result.baseGasFees)
  result.totalFees = getTotalFees(result.maxPriorityFeePerGas, result.baseGasFees, result.gasUsed, result.maxFeePerGas)
  result.maxTotalFees = getMaxTotalFees(result.maxFeePerGas, result.gasLimit)

proc `$`*(self: TransactionDto): string =
  return fmt"""TransactionDto(
    id:{self.id},
    typeValue:{self.typeValue},
    address:{self.address},
    blockNumber:{self.blockNumber},
    blockHash:{self.blockHash},
    contract:{self.contract},
    timestamp:{self.timestamp},
    gasPrice:{self.gasPrice},
    gasLimit:{self.gasLimit},
    gasUsed:{self.gasUsed},
    nonce:{self.nonce},
    txStatus:{self.txStatus},
    value:{self.value},
    tokenId:{self.tokenId},
    fromAddress:{self.fromAddress},
    to:{self.to},
    chainId:{self.chainId},
    maxFeePerGas:{self.maxFeePerGas},
    maxPriorityFeePerGas:{self.maxPriorityFeePerGas},
    input:{self.input},
    txHash:{self.txHash},
    multiTransactionID:{self.multiTransactionID},
    baseGasFees:{self.baseGasFees},
    totalFees:{self.totalFees},
    maxTotalFees:{self.maxTotalFees},
    additionalData:{self.additionalData},
    symbol:{self.symbol}
  )"""

proc toPendingTransactionDto*(jsonObj: JsonNode): TransactionDto =
  result = TransactionDto()
  result.value = "0x" & toHex(toUInt256(parseFloat(jsonObj{"value"}.getStr)))
  result.timestamp = u256(jsonObj{"timestamp"}.getInt)
  result.tokenId = stint.fromHex(UInt256, jsonObj{"tokenId"}.getStr)
  discard jsonObj.getProp("hash", result.txHash)
  discard jsonObj.getProp("from", result.fromAddress)
  discard jsonObj.getProp("to", result.to)
  discard jsonObj.getProp("gasPrice", result.gasPrice)
  discard jsonObj.getProp("gasLimit", result.gasLimit)
  discard jsonObj.getProp("type", result.typeValue)
  discard jsonObj.getProp("network_id", result.chainId)
  discard jsonObj.getProp("multi_transaction_id", result.multiTransactionID)
  discard jsonObj.getProp("additionalData", result.additionalData)
  discard jsonObj.getProp("data", result.input)
  discard jsonObj.getProp("symbol", result.symbol)

proc toMultiTransactionDto*(jsonObj: JsonNode): MultiTransactionDto =
  result = MultiTransactionDto()

  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("timestamp", result.timestamp)
  discard jsonObj.getProp("fromAddress", result.fromAddress)
  discard jsonObj.getProp("toAddress", result.toAddress)
  discard jsonObj.getProp("fromAsset", result.fromAsset)
  discard jsonObj.getProp("toAsset", result.toAsset)
  discard jsonObj.getProp("fromAmount", result.fromAmount)
  discard jsonObj.getProp("toAmount", result.toAmount)
  var multiTxType: int
  discard jsonObj.getProp("type", multiTxType)
  result.multiTxType = cast[MultiTransactionType](multiTxType)

proc cmpTransactions*(x, y: TransactionDto): int =
  # Sort proc to compare transactions from a single account.
  # Compares first by block number, then by nonce
  result = cmp(x.blockNumber.parseHexInt, y.blockNumber.parseHexInt)
  if result == 0:
    result = cmp(x.nonce, y.nonce)

type
  SuggestedFeesDto* = ref object
    gasPrice*: float64
    baseFee*: float64
    maxPriorityFeePerGas*: float64
    maxFeePerGasL*: float64
    maxFeePerGasM*: float64
    maxFeePerGasH*: float64
    eip1559Enabled*: bool

proc decodeSuggestedFeesDto*(jsonObj: JsonNode): SuggestedFeesDto =
  result = SuggestedFeesDto()
  result.gasPrice = jsonObj{"gasPrice"}.getFloat
  result.baseFee = jsonObj{"baseFee"}.getFloat
  result.maxPriorityFeePerGas = jsonObj{"maxPriorityFeePerGas"}.getFloat
  result.maxFeePerGasL = jsonObj{"maxFeePerGasL"}.getFloat
  result.maxFeePerGasM = jsonObj{"maxFeePerGasM"}.getFloat
  result.maxFeePerGasH = jsonObj{"maxFeePerGasH"}.getFloat
  result.eip1559Enabled = jsonObj{"eip1559Enabled"}.getbool

proc toSuggestedFeesDto*(jsonObj: JsonNode): SuggestedFeesDto =
  result = SuggestedFeesDto()
  result.gasPrice = parseFloat(jsonObj["gasPrice"].getStr)
  result.baseFee = parseFloat(jsonObj["baseFee"].getStr)
  result.maxPriorityFeePerGas = parseFloat(jsonObj{"maxPriorityFeePerGas"}.getStr)
  result.maxFeePerGasL = parseFloat(jsonObj{"maxFeePerGasLow"}.getStr)
  result.maxFeePerGasM = parseFloat(jsonObj{"maxFeePerGasMedium"}.getStr)
  result.maxFeePerGasH = parseFloat(jsonObj{"maxFeePerGasHigh"}.getStr)
  result.eip1559Enabled = jsonObj{"eip1559Enabled"}.getbool

proc `$`*(self: SuggestedFeesDto): string =
  return fmt"""SuggestedFees(
    gasPrice:{self.gasPrice},
    baseFee:{self.baseFee},
    maxPriorityFeePerGas:{self.maxPriorityFeePerGas},
    maxFeePerGasL:{self.maxFeePerGasL},
    maxFeePerGasM:{self.maxFeePerGasM},
    maxFeePerGasH:{self.maxFeePerGasH},
    eip1559Enabled:{self.eip1559Enabled}
  )"""

type
  TransactionPathDto* = ref object
    bridgeName*: string
    fromNetwork*: NetworkDto
    toNetwork*: NetworkDto
    maxAmountIn* : UInt256
    amountIn*: UInt256
    amountOut*: UInt256
    gasAmount*: uint64
    gasFees*: SuggestedFeesDto
    tokenFees*: float
    bonderFees*: string
    cost*: float
    estimatedTime*: int
    amountInLocked*: bool
    isFirstSimpleTx*: bool
    isFirstBridgeTx*: bool
    approvalRequired*: bool
    approvalGasFees*: float
    approvalAmountRequired*: UInt256
    approvalContractAddress*: string

proc `$`*(self: TransactionPathDto): string =
  return fmt"""TransactionPath(
    bridgeName:{self.bridgeName},
    fromNetwork:{self.fromNetwork},
    toNetwork:{self.toNetwork},
    maxAmountIn:{self.maxAmountIn},
    amountIn:{self.amountIn},
    amountOut:{self.amountOut},
    gasAmount:{self.gasAmount},
    tokenFees:{self.tokenFees},
    bonderFees:{self.bonderFees},
    cost:{self.cost},
    estimatedTime:{self.estimatedTime},
    amountInLocked:{self.amountInLocked},
    isFirstSimpleTx:{self.isFirstSimpleTx},
    isFirstBridgeTx:{self.isFirstBridgeTx}
    approvalRequired:{self.approvalRequired},
    approvalGasFees:{self.approvalGasFees},
    approvalAmountRequired:{self.approvalAmountRequired},
    approvalContractAddress:{self.approvalContractAddress},
  )"""

proc toTransactionPathDto*(jsonObj: JsonNode): TransactionPathDto =
  result = TransactionPathDto()
  discard jsonObj.getProp("BridgeName", result.bridgeName)
  result.fromNetwork = Json.decode($jsonObj["From"], NetworkDto, allowUnknownFields = true)
  result.toNetwork = Json.decode($jsonObj["To"], NetworkDto, allowUnknownFields = true)
  result.gasFees = jsonObj["GasFees"].toSuggestedFeesDto()
  result.cost = parseFloat(jsonObj{"Cost"}.getStr)
  result.tokenFees = parseFloat(jsonObj{"TokenFees"}.getStr)
  result.bonderFees = jsonObj{"BonderFees"}.getStr
  result.maxAmountIn = stint.fromHex(UInt256, jsonObj{"MaxAmountIn"}.getStr)
  result.amountIn = stint.fromHex(UInt256, jsonObj{"AmountIn"}.getStr)
  result.amountOut = stint.fromHex(UInt256, jsonObj{"AmountOut"}.getStr)
  result.estimatedTime = jsonObj{"EstimatedTime"}.getInt
  discard jsonObj.getProp("GasAmount", result.gasAmount)
  discard jsonObj.getProp("AmountInLocked", result.amountInLocked)
  result.isFirstSimpleTx = false
  result.isFirstBridgeTx = false
  discard jsonObj.getProp("ApprovalRequired", result.approvalRequired)
  result.approvalAmountRequired = stint.fromHex(UInt256, jsonObj{"ApprovalAmountRequired"}.getStr)
  result.approvalGasFees = parseFloat(jsonObj{"ApprovalGasFees"}.getStr)
  discard jsonObj.getProp("ApprovalContractAddress", result.approvalContractAddress)

proc convertToTransactionPathDto*(jsonObj: JsonNode): TransactionPathDto =
  result = TransactionPathDto()
  discard jsonObj.getProp("bridgeName", result.bridgeName)
  result.fromNetwork = Json.decode($jsonObj["fromNetwork"], NetworkDto, allowUnknownFields = true)
  result.toNetwork = Json.decode($jsonObj["toNetwork"], NetworkDto, allowUnknownFields = true)
  result.gasFees = decodeSuggestedFeesDto(jsonObj["gasFees"])
  discard jsonObj.getProp("cost", result.cost)
  discard jsonObj.getProp("tokenFees", result.tokenFees)
  discard jsonObj.getProp("bonderFees", result.bonderFees)
  result.maxAmountIn = stint.u256(jsonObj{"maxAmountIn"}.getStr)
  result.amountIn = stint.u256(jsonObj{"amountIn"}.getStr)
  result.amountOut = stint.u256(jsonObj{"amountOut"}.getStr)
  result.estimatedTime = jsonObj{"estimatedTime"}.getInt
  discard jsonObj.getProp("gasAmount", result.gasAmount)
  discard jsonObj.getProp("approvalRequired", result.approvalRequired)
  result.approvalAmountRequired = stint.u256(jsonObj{"approvalAmountRequired"}.getStr)
  discard jsonObj.getProp("approvalGasFees", result.approvalGasFees)
  discard jsonObj.getProp("approvalContractAddress", result.approvalContractAddress)

type
  Fees* = ref object
    totalFeesInEth*: float
    totalTokenFees*: float
    totalTime*: int

type
  SendToNetwork* = ref object
    chainId*: int
    chainName*: string
    iconUrl*: string
    amountOut*: UInt256

type
  SuggestedRoutesDto* = ref object
    best*: seq[TransactionPathDto]
    gasTimeEstimate*: Fees
    amountToReceive*: UInt256
    toNetworks*: seq[SendToNetwork]
