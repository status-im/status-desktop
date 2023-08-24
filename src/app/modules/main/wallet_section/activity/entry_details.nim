import NimQml, json, stint, strutils

import backend/activity as backend

import app/modules/shared_models/currency_amount

import web3/ethtypes as eth
import web3/conversions

type
  AmountToCurrencyConvertor* = proc (amount: UInt256, symbol: string): CurrencyAmount

QtObject:
  type
    ActivityDetails* = ref object of QObject
      id*: string
      multiTxId: int
      nonce*: int
      blockNumber*: int
      protocolType*: Option[backend.ProtocolType]
      txHash*: string
      input*: string
      contractAddress: Option[eth.Address]
      maxTotalFees: CurrencyAmount

  proc setup(self: ActivityDetails) =
    self.QObject.setup

  proc delete*(self: ActivityDetails) =
    self.QObject.delete

  proc getMaxTotalFees(maxFee: string, gasLimit: string): string =
    return (stint.fromHex(Uint256, maxFee) * stint.fromHex(Uint256, gasLimit)).toHex

  proc newActivityDetails*(id: string, isMultiTx: bool): ActivityDetails =
    new(result, delete)
    if isMultiTx:
      result.multiTxId = parseInt(id)
    else:
      result.id = id
    result.maxTotalFees = newCurrencyAmount()
    result.setup()

  proc newActivityDetails*(e: JsonNode, valueConvertor: AmountToCurrencyConvertor): ActivityDetails =
    new(result, delete)
    const protocolTypeField = "protocolType"
    const hashField = "hash"
    const contractAddressField = "contractAddress"
    const inputField = "input"

    result = ActivityDetails(
      id: e["id"].getStr(),
      multiTxId: e["multiTxId"].getInt(),
      nonce: e["nonce"].getInt(),
      blockNumber: e["blockNumber"].getInt()
    )
    let maxFeePerGas = e["maxFeePerGas"].getStr()
    let gasLimit = e["gasLimit"].getStr()
    if len(maxFeePerGas) > 0 and len(gasLimit) > 0:
      let maxTotalFees = getMaxTotalFees(maxFeePerGas, gasLimit)
      result.maxTotalFees = valueConvertor(stint.fromHex(UInt256, maxTotalFees), "Gwei")
    else:
      result.maxTotalFees = newCurrencyAmount()

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
    result.setup()


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