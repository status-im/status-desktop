import json

import base
import signal_type

type WalletSignal* = ref object of Signal
  content*: string
  eventType*: string
  blockNumber*: int
  accounts*: seq[string]
  # newTransactions*: ???
  erc20*: bool

proc fromEvent*(T: type WalletSignal, jsonSignal: JsonNode): WalletSignal =
  result = WalletSignal()
  result.signalType = SignalType.Wallet
  result.content = $jsonSignal
  if jsonSignal["event"].kind != JNull:
    result.eventType = jsonSignal["event"]["type"].getStr
    result.blockNumber = jsonSignal["event"]{"blockNumber"}.getInt
    result.erc20 = jsonSignal["event"]{"erc20"}.getBool
    result.accounts = @[]
    if jsonSignal["event"]["accounts"].kind != JNull:
      for account in jsonSignal["event"]["accounts"]:
        result.accounts.add(account.getStr)
