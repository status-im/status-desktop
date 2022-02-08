import json
import ./core, ./response_type

export response_type

proc getCustomTokens*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return callPrivateRPC("wallet_getCustomTokens", %* [])

proc addCustomToken*(
  chainId: int, address: string, name: string, symbol: string, decimals: int, color: string
) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_addCustomToken", %* [
    {"chainId": chainId, "address": address, "name": name, "symbol": symbol, "decimals": decimals, "color": color}
  ])

proc removeCustomToken*(chainId: int, address: string) {.raises: [Exception].} =
  discard callPrivateRPC("wallet_deleteCustomTokenByChainID", %* [chainId, address])
