import json, chronicles, strformat, stint, strutils
import core, wallet
import contracts
import eth/common/eth_types, eth/common/utils
import json_serialization
import settings
from types import Setting, Network
import default_tokens
import strutils
import locks

logScope:
  topics = "wallet"

var customTokensLock: Lock
initLock(customTokensLock)

var customTokens {.guard: customTokensLock.} = %*{}
var dirty {.guard: customTokensLock.}  = true

proc getCustomTokens*(useCached: bool = true): JsonNode =
  {.gcsafe.}:
    withLock customTokensLock:
      if useCached and not dirty:
        result = customTokens
      else: 
        let payload = %* []
        result = callPrivateRPC("wallet_getCustomTokens", payload).parseJSON()["result"]
        if result.kind == JNull: result = %* []
        dirty = false
        customTokens = result

proc getTokenBySymbol*(tokenList: JsonNode, symbol: string): JsonNode =
  for defToken in tokenList.getElems():
    if defToken["symbol"].getStr == symbol:
      return defToken
  return newJNull()

proc getTokenByAddress*(tokenList: JsonNode, address: string): JsonNode =
  for defToken in tokenList.getElems():
    if defToken["address"].getStr == address:
      return defToken
  return newJNull()

proc visibleTokensSNTDefault(): JsonNode =
  let currentNetwork = getSetting[string](Setting.Networks_CurrentNetwork)
  let SNT = if getCurrentNetwork() == Network.Testnet: "STT" else: "SNT"
  let response = getSetting[string](Setting.VisibleTokens, "{\"" & currentNetwork & "\": [\"" & SNT & "\"]}")
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

proc hideAsset*(symbol: string) =
  let currentNetwork = getSetting[string](Setting.Networks_CurrentNetwork)
  let visibleTokens = visibleTokensSNTDefault()
  var visibleTokenList = visibleTokens[currentNetwork].to(seq[string])
  var symbolIdx = visibleTokenList.find(symbol)
  if symbolIdx > -1:
    visibleTokenList.del(symbolIdx)
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
    let t = getTokenBySymbol(getDefaultTokens(), v)
    if t.kind != JNull: result.elems.add(t)
    let ct = getTokenBySymbol(getCustomTokens(), v)
    if ct.kind != JNull: result.elems.add(ct)
  
proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string) =
  let payload = %* [{"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}]
  discard callPrivateRPC("wallet_addCustomToken", payload)
  withLock customTokensLock:
    dirty = true

proc removeCustomToken*(address: string) =
  let payload = %* [address]
  echo callPrivateRPC("wallet_deleteCustomToken", payload)
  withLock customTokensLock:
    dirty = true

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

  var decimals = 18
  let t = getTokenByAddress(getDefaultTokens(), tokenAddress)
  let ct = getTokenByAddress(getCustomTokens(), tokenAddress)
  if t.kind != JNull: 
    decimals = t["decimals"].getInt
  elif ct.kind != JNull: 
    decimals = ct["decimals"].getInt

  result = $hex2Token(balance, decimals)

proc getSNTAddress*(): string =
  let snt = contracts.getContract("snt")
  result = "0x" & $snt.address

proc getSNTBalance*(account: string): string =
  let snt = contracts.getContract("snt")
  result = getTokenBalance("0x" & $snt.address, account)
