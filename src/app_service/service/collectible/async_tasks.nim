type
  GetCollectionsTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string

const getCollectionsTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCollectionsTaskArg](argEncoded)
  let output = %* {
    "chainId": arg.chainId,
    "address": arg.address,
    "collections": ""
  }
  try:
    let response = backend.getOpenseaCollectionsByOwner(arg.chainId, arg.address)
    output["collections"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error getCollectionsTaskArg: ", errDesription
  arg.finish(output)

type
  GetCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string
    collectionSlug: string
    limit: int

const getCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCollectiblesTaskArg](argEncoded)
  let output = %* {
    "chainId": arg.chainId,
    "address": arg.address,
    "collectionSlug": arg.collectionSlug,
    "collectibles": ""
  }
  try:
    let response = backend.getOpenseaAssetsByOwnerAndCollection(arg.chainId, arg.address, arg.collectionSlug, arg.limit)
    output["collectibles"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error getCollectiblesTaskArg: ", errDesription
  arg.finish(output)
