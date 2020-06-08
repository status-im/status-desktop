import core as status
import json
import chronicles
import strformat
import stint
import strutils
import wallet

logScope:
  topics = "wallet"

proc getCustomTokens*(): JsonNode =
  let payload = %* []
  let response = status.callPrivateRPC("wallet_getCustomTokens", payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string) =
  let payload = %* [{"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}]
  discard status.callPrivateRPC("wallet_addCustomToken", payload)

proc removeCustomToken*(address: string) =
  let payload = %* [address]
  discard status.callPrivateRPC("wallet_deleteCustomToken", payload)

proc getTokensBalances*(accounts: openArray[string], tokens: openArray[string]): JsonNode =
  let payload = %* [accounts, tokens]
  let response = status.callPrivateRPC("wallet_getTokensBalances", payload).parseJson
  if response["result"].kind == JNull:
    return %* {}
  response["result"]

proc getTokenBalance*(tokenAddress: string, account: string): string = 
  var postfixedAccount: string = account
  postfixedAccount.removePrefix("0x")
  let payload = %* [{
    "to": tokenAddress, "from": account, "data": fmt"0x70a08231000000000000000000000000{postfixedAccount}"
  }, "latest"]
  var response = status.callPrivateRPC("eth_call", payload)
  var balance = response.parseJson["result"].getStr
  result = $hex2Eth(balance)

proc addOrRemoveToken*(enable: bool, address: string, name: string, symbol: string, decimals: int, color: string): JsonNode =
  if enable:
    addCustomToken(address, name, symbol, decimals, color)
  else:
    removeCustomToken(address)
  getCustomTokens()
