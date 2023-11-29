import json, tables, stint, strutils, net, sequtils, options, chronicles, strformat

import token
import balance
import backend/backend

proc getTokenBalanceForAccount*(chainId: int, accAddress: string, symbol: string): Option[BalanceDto] =
  try:
    let response = backend.getWalletToken(@[accAddress])
    if not response.result.contains(accAddress):
      error "Missing balance for account ", accAddress
      return none[BalanceDto]()

    let tokens = parseWalletTokenDtoJson(response.result[accAddress])
    for token in tokens:
      if token.symbol == symbol:
        if chainId in token.balancesPerChain:
          return some(token.balancesPerChain[chainId])

  except Exception as e:
    error "Error getting balance ", message=e.msg

  return none[BalanceDto]()
