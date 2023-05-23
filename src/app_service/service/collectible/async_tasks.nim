type
  FetchOwnedCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    address*: string
    cursor: string
    limit: int

const fetchOwnedCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchOwnedCollectiblesTaskArg](argEncoded)
  try:
    let response = collectibles.getOpenseaAssetsByOwnerWithCursor(arg.chainId, arg.address, arg.cursor, arg.limit)

    if not response.error.isNil:
      raise newException(ValueError, "Error getOpenseaAssetsByOwnerWithCursor" & response.error.message)

    let output = %* {
      "chainId": arg.chainId,
      "address": arg.address,
      "cursor": arg.cursor,
      "collectibles": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "chainId": arg.chainId,
      "address": arg.address,
      "cursor": arg.cursor,
      "collectibles": "",
      "error": e.msg
    }
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
  try:
    let response = collectibles.getOpenseaAssetsByOwnerAndContractAddressWithCursor(arg.chainId, arg.address, arg.contractAddresses, arg.cursor, arg.limit)

    if not response.error.isNil:
      raise newException(ValueError, "Error getOpenseaAssetsByOwnerAndContractAddressWithCursor" & response.error.message)

    let output = %* {
      "chainId": arg.chainId,
      "address": arg.address,
      "cursor": arg.cursor,
      "collectibles": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "chainId": arg.chainId,
      "address": arg.address,
      "cursor": arg.cursor,
      "collectibles": "",
      "error": e.msg
    }
    arg.finish(output)

type
  FetchCollectiblesTaskArg = ref object of QObjectTaskArg
    chainId*: int
    ids*: seq[collectibles.NFTUniqueID]
    limit: int

const fetchCollectiblesTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchCollectiblesTaskArg](argEncoded)
  try:
    let response = collectibles.getOpenseaAssetsByNFTUniqueID(arg.chainId, arg.ids, arg.limit)

    if not response.error.isNil:
      raise newException(ValueError, "Error getOpenseaAssetsByNFTUniqueID" & response.error.message)

    let output = %* {
      "chainId": arg.chainId,
      "collectibles": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "chainId": arg.chainId,
      "collectibles": "",
      "error": e.msg
    }
    arg.finish(output)
