type
  FetchCollectionsTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string

const fetchCollectionsTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchCollectionsTaskArg](argEncoded)
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
    error "error fetchCollectionsTaskArg: ", errDesription
  arg.finish(output)

type
  FetchCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string
    collectionSlug: string
    limit: int

const fetchCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchCollectiblesTaskArg](argEncoded)
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
    error "error fetchCollectiblesTaskArg: ", errDesription
  arg.finish(output)
