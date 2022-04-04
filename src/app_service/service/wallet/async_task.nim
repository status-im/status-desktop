type
  FetchWalletTaskArg = ref object of QObjectTaskArg
    chainIds*: seq[int]

const fetchWalletTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchWalletTaskArg](argEncoded)
  let response = backend.getWallet(arg.chainIds)
  arg.finish(response.result)