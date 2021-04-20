import json
import types

proc fromEvent*(jsonSignal: JsonNode): Signal = 
  var signal:WalletSignal = WalletSignal()
  signal.content = $jsonSignal  
  if jsonSignal["event"].kind != JNull:
    signal.eventType = jsonSignal["event"]["type"].getStr
    signal.blockNumber = jsonSignal["event"]{"blockNumber"}.getInt
    signal.erc20 = jsonSignal["event"]{"erc20"}.getBool
    signal.accounts = @[]
    for account in jsonSignal["event"]["accounts"]:
      signal.accounts.add(account.getStr)
  result = signal
  