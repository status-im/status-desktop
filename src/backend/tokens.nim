import json
import ./core, ./response_type

export response_type


proc getTokens*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getTokens", %* [chainId])

proc getBalances*(chainIds: seq[int], accounts: seq[string], tokens: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getTokensBalancesForChainIDs", %* [chainIds, accounts, tokens])
