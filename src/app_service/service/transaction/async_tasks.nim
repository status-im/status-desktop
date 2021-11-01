include ../../common/json_utils
include ../../tasks/common

#################################################
# Async load transactions
#################################################

type
  LoadTransactionsTaskArg* = ref object of QObjectTaskArg
    address: string
    toBlock: Uint256
    limit: int
    loadMore: bool

const loadTransactionsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadTransactionsTaskArg](argEncoded)
    output = %*{
      "address": arg.address,
      "history": transactions.getTransfersByAddress(arg.address, arg.toBlock, arg.limit, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)
