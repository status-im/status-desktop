import json

include  app_service/common/json_utils

type
  TxResponseDto* = ref object
    keyUid*: string
    address*: string
    addressPath*: string
    signOnKeycard*: bool
    chainId*: int
    messageToSign*: string
    txArgsJson*: JsonNode
    rawTx*: string
    txHash*: string

proc toTxResponseDto*(jsonObj: JsonNode): TxResponseDto =
  result = TxResponseDto()
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("addressPath", result.addressPath)
  discard jsonObj.getProp("signOnKeycard", result.signOnKeycard)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("messageToSign", result.messageToSign)
  discard jsonObj.getProp("txArgs", result.txArgsJson)
  discard jsonObj.getProp("rawTx", result.rawTx)
  discard jsonObj.getProp("txHash", result.txHash)