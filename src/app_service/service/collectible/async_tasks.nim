type
  GetCollectionsTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string

const getCollectionsTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCollectionsTaskArg](argEncoded)

  try:
    let response = backend.getOpenseaCollectionsByOwner(arg.chainId, arg.address)
    arg.finish(response.result)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    arg.finish("")

  