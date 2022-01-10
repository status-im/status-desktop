import json, strutils, stint
include  ../../common/json_utils

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
    fromAddress*: string
    to*: string

proc toTransactionDto*(jsonObj: JsonNode): TransactionDto =
  result = TransactionDto()
  result.timestamp = stint.fromHex(UInt256, jsonObj{"timestamp"}.getStr)
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
