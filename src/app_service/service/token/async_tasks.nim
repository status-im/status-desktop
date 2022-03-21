# include strformat, json
include ../../common/json_utils
import ../eth/utils

import ../../../backend/backend as backend
#################################################
# Async load transactions
#################################################

type
  GetTokenDetailsTaskArg = ref object of QObjectTaskArg
    chainId: int
    address: string


const getTokenDetailsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenDetailsTaskArg](argEncoded)
  try:
    let response = backend.discoverToken(arg.chainId, arg.address).result
    
    let output = %* {
      "address": arg.address,
      "name": response{"name"}.getStr,
      "symbol": response{"symbol"}.getStr,
      "decimals": response{"decimals"}.getInt
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "address": arg.address,
      "error": "Is this an ERC-20 or ERC-721 contract?",
    }
    arg.finish(output)
