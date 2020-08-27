import json, chronicles, strformat, stint, strutils
import core, wallet
import contracts
import eth/common/eth_types, eth/common/utils, stew/byteutils
import json_serialization

logScope:
  topics = "wallet"

proc getCustomTokens*(): JsonNode =
  let payload = %* []
  let response = callPrivateRPC("wallet_getCustomTokens", payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string) =
  let payload = %* [{"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}]
  discard callPrivateRPC("wallet_addCustomToken", payload)

proc removeCustomToken*(address: string) =
  let payload = %* [address]
  discard callPrivateRPC("wallet_deleteCustomToken", payload)

proc getTokensBalances*(accounts: openArray[string], tokens: openArray[string]): JsonNode =
  let payload = %* [accounts, tokens]
  let response = callPrivateRPC("wallet_getTokensBalances", payload).parseJson
  if response["result"].kind == JNull:
    return %* {}
  response["result"]

proc getTokenBalance*(tokenAddress: string, account: string): string = 
  var postfixedAccount: string = account
  postfixedAccount.removePrefix("0x")
  let payload = %* [{
    "to": tokenAddress, "from": account, "data": fmt"0x70a08231000000000000000000000000{postfixedAccount}"
  }, "latest"]
  let response = callPrivateRPC("eth_call", payload)
  let balance = response.parseJson["result"].getStr
  result = $hex2Eth(balance)

proc getSNTAddress*(): string =
  let snt = contracts.getContract("snt")
  result = "0x" & $snt.address

proc getSNTBalance*(account: string): string =
  let snt = contracts.getContract("snt")
  result = getTokenBalance("0x" & $snt.address, account)

proc addOrRemoveToken*(enable: bool, address: string, name: string, symbol: string, decimals: int, color: string): JsonNode =
  if enable:
    addCustomToken(address, name, symbol, decimals, color)
  else:
    removeCustomToken(address)
  getCustomTokens()
