#################################################
# Async load transactions
#################################################

type
  LoadTransactionsTaskArg* = ref object of QObjectTaskArg
    chainId: int
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
      "chainId": arg.chainId,
      "history": transactions.getTransfersByAddress(arg.chainId, arg.address, arg.toBlock, limitAsHex, arg.loadMore),
      "loadMore": arg.loadMore
    }
  arg.finish(output)
