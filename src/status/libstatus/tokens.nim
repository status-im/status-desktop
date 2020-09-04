import json, chronicles, strformat, stint, strutils
import core, wallet
import contracts
import eth/common/eth_types, eth/common/utils
import json_serialization
import settings
from types import Setting, Network
import default_tokens
import strutils

logScope:
  topics = "wallet"

proc getCustomTokens*(): JsonNode =
  let payload = %* []
  let response = callPrivateRPC("wallet_getCustomTokens", payload).parseJson
  if response["result"].kind == JNull:
    return %* []
  return response["result"]

proc visibleTokensSNTDefault(): JsonNode =
  let currentNetwork = getSetting[string](Setting.Networks_CurrentNetwork)
  let SNT = if getCurrentNetwork() == Network.Testnet: "STT" else: "SNT"
  let response = getSetting[string](Setting.VisibleTokens, "{\"" & currentNetwork & "\": [\"" & SNT & "\"]}")
  echo response
  result = response.parseJson

proc toggleAsset*(symbol: string) =
  let currentNetwork = getSetting[string](Setting.Networks_CurrentNetwork)
  let visibleTokens = visibleTokensSNTDefault()
  var visibleTokenList = visibleTokens[currentNetwork].to(seq[string])
  var symbolIdx = visibleTokenList.find(symbol)
  if symbolIdx > -1:
    visibleTokenList.del(symbolIdx)
  else:
    visibleTokenList.add symbol
  visibleTokens[currentNetwork] = newJArray()
  visibleTokens[currentNetwork] = %* visibleTokenList
  discard saveSetting(Setting.VisibleTokens, $visibleTokens)

proc getVisibleTokens*(): JsonNode =
  let currentNetwork = getSetting[string](Setting.Networks_CurrentNetwork)
  let visibleTokens = visibleTokensSNTDefault()
  let visibleTokenList = visibleTokens[currentNetwork].to(seq[string])
  let customTokens = getCustomTokens()

  result = newJArray()

  for v in visibleTokenList:
    let t = getTokenBySymbol(v)
    if t.kind != JNull: result.elems.add(t)

  for custToken in customTokens.getElems():
    for v in visibleTokenList:
      if custToken["symbol"].getStr == v:
        result.elems.add(custToken)
        break

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

  let t = getTokenByAddress(tokenAddress)
  var decimals = 18
  if t.kind != JNull: decimals = t["decimals"].getInt
  result = $hex2Token(balance, decimals)

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
