import json, options

import base
import signal_type

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

proc fromEvent*(T: type WalletSignal, jsonSignal: JsonNode): WalletSignal =
  result = WalletSignal()
  result.signalType = SignalType.Wallet
  result.content = $jsonSignal
  let event = jsonSignal["event"]
  if event.kind != JNull:
    result.eventType = event["type"].getStr
    result.blockNumber = event{"blockNumber"}.getInt
    result.erc20 = event{"erc20"}.getBool
    result.accounts = @[]
    if event["accounts"].kind != JNull:
      for account in event["accounts"]:
        result.accounts.add(account.getStr)
    result.at = event{"at"}.getInt
    result.chainID = event{"chainID"}.getInt
    result.message = event{"message"}.getStr
    const requestIdName = "requestId"
    if event.contains(requestIdName):
      result.requestId = some(event[requestIdName].getInt())
