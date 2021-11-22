# include strformat, json
include ../../common/json_utils
include ../../../app/core/tasks/common
import status/[utils, tokens]

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
    let 
      tkn = newErc20Contract(arg.chainId, arg.address.parseAddress)
      decimals = tkn.tokenDecimals()
      output = %* {
        "address": arg.address,
        "name": tkn.tokenName(),
        "symbol": tkn.tokenSymbol(),
        "decimals": (if decimals == 0: "" else: $decimals)
      }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "address": arg.address,
      "error": fmt"{e.msg}. Is this an ERC-20 or ERC-721 contract?",
    }
    arg.finish(output)
