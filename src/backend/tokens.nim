import json
import ./core, ./response_type

export response_type


proc getTokens*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getTokens", %* [chainId])

proc getBalances*(chainId: int, accounts: seq[string], tokens: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getTokensBalancesForChainIDs", %* [@[chainId], accounts, tokens])

proc getCustomTokens*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getCustomTokens", %* [])

proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_addCustomToken", %* [
    {"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}
  ])

proc removeCustomToken*(address: string) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_deleteCustomToken", %* [address])
