import NimQml, json, stint, strutils, logging, options

import backend/activity as backend
import backend/backend as common_backend

import app/modules/shared_models/currency_amount

import web3/ethtypes as eth
import web3/conversions

type
  AmountToCurrencyConvertor* = proc (amount: UInt256, symbol: string): CurrencyAmount

QtObject:
  type
    ActivityDetails* = ref object of QObject
      id*: string

      metadata: backend.ActivityEntry

      # TODO use medatada
      multiTxId: int
      nonce*: int
      blockNumber*: int
      protocolType*: Option[backend.ProtocolType]
      txHash*: string
      input*: string
      contractAddress: Option[eth.Address]
      maxTotalFees: CurrencyAmount
      totalFees: CurrencyAmount

  proc setup(self: ActivityDetails) =
    self.QObject.setup

  proc delete*(self: ActivityDetails) =
    self.QObject.delete

  proc getMaxTotalFees(maxFee: string, gasLimit: string): string =
    return (stint.fromHex(Uint256, maxFee) * stint.fromHex(Uint256, gasLimit)).toHex

  proc newActivityDetails*(metadata: backend.ActivityEntry, valueConvertor: AmountToCurrencyConvertor): ActivityDetails =
    new(result, delete)
    defer: result.setup()

    result.maxTotalFees = newCurrencyAmount()
    result.totalFees = newCurrencyAmount()

    var e: JsonNode
    case metadata.getPayloadType():
      of PendingTransaction:
        result.id = metadata.getTransactionIdentity().get().hash
        return
      of MultiTransaction:
        result.multiTxId = metadata.getMultiTransactionId.get(0)
        let res = backend.getMultiTxDetails(metadata.getMultiTransactionId().get(0))
        if res.error != nil:
          error "failed to fetch multi tx details: ", metadata.getMultiTransactionId()
          return
        e = res.result
      of SimpleTransaction:
        let res = backend.getTxDetails(metadata.getTransactionIdentity().get().hash)
        if res.error != nil:
          error "failed to fetch tx details: ", metadata.getTransactionIdentity().get().hash
          return
        e = res.result

    const protocolTypeField = "protocolType"
    const hashField = "hash"
    const contractAddressField = "contractAddress"
    const inputField = "input"
    const totalFeesField = "totalFees"

    result.id = e["id"].getStr()
    result.multiTxId = e["multiTxId"].getInt()
    result.nonce = e["nonce"].getInt()
    result.blockNumber = e["blockNumber"].getInt()

    let maxFeePerGas = e["maxFeePerGas"].getStr()
    let gasLimit = e["gasLimit"].getStr()

    const gweiSymbol = "Gwei"

    if len(maxFeePerGas) > 0 and len(gasLimit) > 0:
      let maxTotalFees = getMaxTotalFees(maxFeePerGas, gasLimit)
      result.maxTotalFees = valueConvertor(stint.fromHex(UInt256, maxTotalFees), gweiSymbol)

    if e.hasKey(totalFeesField) and e[totalFeesField].kind != JNull:
      let totalFees = e[totalFeesField].getStr()
      let resTotalFees = valueConvertor(stint.fromHex(UInt256, totalFees), gweiSymbol)
      if resTotalFees != nil:
        result.totalFees = resTotalFees

    if e.hasKey(hashField) and e[hashField].kind != JNull:
      result.txHash = e[hashField].getStr()
    if e.hasKey(protocolTypeField) and e[protocolTypeField].kind != JNull:
      result.protocolType = some(fromJson(e[protocolTypeField], backend.ProtocolType))
    if e.hasKey(inputField) and e[inputField].kind != JNull:
      result.input = e[inputField].getStr()
    if e.hasKey(contractAddressField) and e[contractAddressField].kind != JNull:
      var contractAddress: eth.Address
      fromJson(e[contractAddressField], contractAddressField, contractAddress)
      result.contractAddress = some(contractAddress)

  proc getNonce*(self: ActivityDetails): int {.slot.} =
    return self.nonce

  QtProperty[int] nonce:
    read = getNonce

  proc getBlockNumber*(self: ActivityDetails): int {.slot.} =
    return self.blockNumber

  QtProperty[int] blockNumber:
    read = getBlockNumber

  proc getProtocol*(self: ActivityDetails): string {.slot.} =
    if self.protocolType.isSome():
      return $self.protocolType.unsafeGet()
    return ""

  QtProperty[string] protocol:
    read = getProtocol

  proc getTxHash*(self: ActivityDetails): string {.slot.} =
    return self.txHash

  QtProperty[string] txHash:
    read = getTxHash

  proc getInput*(self: ActivityDetails): string {.slot.} =
    return self.input

  QtProperty[string] input:
    read = getInput

  proc getContract*(self: ActivityDetails): string {.slot.} =
    return if self.contractAddress.isSome(): "0x" & self.contractAddress.unsafeGet().toHex() else: ""

  QtProperty[string] contract:
    read = getContract

  proc getMaxTotalFees*(self: ActivityDetails): QVariant {.slot.} =
    return newQVariant(self.maxTotalFees)

  QtProperty[QVariant] maxTotalFees:
    read = getMaxTotalFees

  proc getTotalFees*(self: ActivityDetails): QVariant {.slot.} =
    return newQVariant(self.totalFees)

  QtProperty[QVariant] totalFees:
    read = getTotalFees

  proc getTokenType*(self: ActivityDetails): string {.slot.} =
    if self.metadata.tokenIn.isSome:
      return $self.metadata.tokenIn.get().tokenType
    if self.metadata.tokenOut.isSome:
      return $self.metadata.tokenOut.get().tokenType
    return ""

  QtProperty[string] tokenType:
    read = getTokenType

