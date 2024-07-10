import json, options, chronicles

import base
import signal_type

import app_service/service/transaction/dtoV2

const SignTransactionsEventType* = "sing-transactions"

type WalletSignal* = ref object of Signal
  content*: string
  eventType*: string
  blockNumber*: int
  accounts*: seq[string]
  # newTransactions*: ???
  erc20*: bool
  at*: int
  chainID*: int
  message*: string
  requestId*: Option[int]
  txHashes*: seq[string]
  uuid*: string
  bestRouteRaw*: string
  bestRoute*: seq[TransactionPathDtoV2]
  error*: string
  errorCode*: string

proc fromEvent*(T: type WalletSignal, signalType: SignalType, jsonSignal: JsonNode): WalletSignal =
  result = WalletSignal()
  result.signalType = SignalType.Wallet
  let event = jsonSignal["event"]
  if event.kind == JNull:
    return
  if signalType == SignalType.Wallet:
    result.content = $jsonSignal
    result.eventType = event["type"].getStr
    result.blockNumber = event{"blockNumber"}.getInt
    result.erc20 = event{"erc20"}.getBool
    result.accounts = @[]
    if event["accounts"].kind != JNull:
      for account in event["accounts"]:
        result.accounts.add(account.getStr)
    result.at = event{"at"}.getInt
    result.chainID = event{"chainId"}.getInt
    result.message = event{"message"}.getStr
    const requestIdName = "requestId"
    if event.contains(requestIdName):
      result.requestId = some(event[requestIdName].getInt())
    return
  if signalType == SignalType.WalletSignTransactions:
    if event.kind != JArray:
      return
    for tx in event:
      result.txHashes.add(tx.getStr)
    return
  if signalType == SignalType.WalletSuggestedRoutes:
    try:
      if event.contains("Uuid"):
        result.uuid = event["Uuid"].getStr()
      if event.contains("Best"):
        let bestRouteJsonNode = event["Best"]
        result.bestRouteRaw = $bestRouteJsonNode
        result.bestRoute = bestRouteJsonNode.toTransactionPathsDtoV2()
      if event.contains("ErrorResponse"):
        let errorResponseJsonNode = event["ErrorResponse"]
        if errorResponseJsonNode.contains("details"):
          result.error = errorResponseJsonNode["details"].getStr
        if errorResponseJsonNode.contains("code"):
          result.errorCode = errorResponseJsonNode["code"].getStr
    except:
      error "Error parsing best route"
    return
