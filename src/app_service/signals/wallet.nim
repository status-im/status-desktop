import json

import base

type WalletSignal* = ref object of Signal
  content*: string
  eventType*: string
  blockNumber*: int
  accounts*: seq[string]
  # newTransactions*: ???
  erc20*: bool

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:WalletSignal = WalletSignal()
  signal.content = $jsonSignal  
  if jsonSignal["event"].kind != JNull:
    signal.eventType = jsonSignal["event"]["type"].getStr
    signal.blockNumber = jsonSignal["event"]{"blockNumber"}.getInt
    signal.erc20 = jsonSignal["event"]{"erc20"}.getBool
    signal.accounts = @[]
    if jsonSignal["event"]["accounts"].kind != JNull:
      for account in jsonSignal["event"]["accounts"]:
        signal.accounts.add(account.getStr)
  result = signal
  