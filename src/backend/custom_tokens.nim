import json
import ./core, ./response_type

export response_type

proc getCustomTokens*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getCustomTokens", %* [])

proc addCustomToken*(address: string, name: string, symbol: string, decimals: int, color: string) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_addCustomToken", %* [
    {"address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}
  ])

proc removeCustomToken*(address: string) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_deleteCustomToken", %* [address])
