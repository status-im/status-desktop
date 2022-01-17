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
    limitAsHex = "0x" & eth_utils.stripLeadingZeros(arg.limit.toHex)
    output = %*{
      "address": arg.address,
      "history": transactions.getTransfersByAddress(arg.address, arg.toBlock, limitAsHex, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)
