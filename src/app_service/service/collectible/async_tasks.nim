type
  FetchOwnedCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string
    cursor: string
    limit: int

const fetchOwnedCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchOwnedCollectiblesTaskArg](argEncoded)
  let output = %* {
    "chainId": arg.chainId,
    "address": arg.address,
    "cursor": arg.cursor,
    "collectibles": {"assets":nil,"next":"","previous":""}
  }
  try:
    let response = collectibles.getOpenseaAssetsByOwnerWithCursor(arg.chainId, arg.address, arg.cursor, arg.limit)
    output["collectibles"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error fetchOwnedCollectiblesTaskArg: ", errDesription
  arg.finish(output)

type
  FetchOwnedCollectiblesFromContractAddressesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string
    contractAddresses*: seq[string]
    cursor: string
    limit: int

const fetchOwnedCollectiblesFromContractAddressesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchOwnedCollectiblesFromContractAddressesTaskArg](argEncoded)
  let output = %* {
    "chainId": arg.chainId,
    "address": arg.address,
    "cursor": arg.cursor,
    "collectibles": ""
  }
  try:
    let response = collectibles.getOpenseaAssetsByOwnerAndContractAddressWithCursor(arg.chainId, arg.address, arg.contractAddresses, arg.cursor, arg.limit)
    output["collectibles"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error fetchOwnedCollectiblesFromContractAddressesTaskArg: ", errDesription
  arg.finish(output)

type
  FetchCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    ids*: seq[collectibles.NFTUniqueID]
    limit: int

const fetchCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchCollectiblesTaskArg](argEncoded)
  let output = %* {
    "chainId": arg.chainId,
    "collectibles": ""
  }
  try:
    let response = collectibles.getOpenseaAssetsByNFTUniqueID(arg.chainId, arg.ids, arg.limit)
    output["collectibles"] = response.result
  except Exception as e:
    let errDesription = e.msg
    error "error fetchCollectiblesTaskArg: ", errDesription
  arg.finish(output)
