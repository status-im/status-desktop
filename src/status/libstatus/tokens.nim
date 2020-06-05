import core as status
import json
import chronicles

logScope:
  topics = "wallet"

proc getCustomTokens*(): JsonNode =
  let payload = %* []
  let response = status.callPrivateRPC("wallet_getCustomTokens", payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string): string =
  let payload = %* [{"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}]
  status.callPrivateRPC("wallet_addCustomToken", payload)

proc removeCustomToken*(address: string): string =
  let payload = %* [address]
  status.callPrivateRPC("wallet_deleteCustomToken", payload)

proc getTokensBalances*(accounts: openArray[string], tokens: openArray[string]): JsonNode =
  let payload = %* [accounts, tokens]
  let response = status.callPrivateRPC("wallet_getTokensBalances", payload).parseJson
  if response["result"].kind == JNull:
    return %* {}
  response["result"]
