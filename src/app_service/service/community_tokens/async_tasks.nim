import stint
include ../../common/json_utils
import ../../../backend/eth
import ../../../backend/community_tokens
import ../../../backend/collectibles
import ../../../app/core/tasks/common
import ../../../app/core/tasks/qt
import ../transaction/dto

type
  AsyncGetSuggestedFees = ref object of QObjectTaskArg
    chainId: int

const asyncGetSuggestedFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetSuggestedFees](argEncoded)
  try:
    let response = eth.suggestedFees(arg.chainId).result
    arg.finish(%* {
      "fees": response.toSuggestedFeesDto(),
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncGetBurnFees = ref object of QObjectTaskArg
    chainId: int
    contractAddress: string
    tokenIds: seq[UInt256]

const asyncGetBurnFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetBurnFees](argEncoded)
  try:
    let feesResponse = eth.suggestedFees(arg.chainId).result
    let burnGas = community_tokens.estimateRemoteBurn(arg.chainId, arg.contractAddress, arg.tokenIds).result.getInt
    arg.finish(%* {
      "fees": feesResponse.toSuggestedFeesDto(),
      "burnGas": burnGas,
      "error": "" })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  FetchCollectibleOwnersArg = ref object of QObjectTaskArg
    chainId*: int
    contractAddress*: string
    communityId*: string

const fetchCollectibleOwnersTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchCollectibleOwnersArg](argEncoded)
  try:
    let response = collectibles.getCollectibleOwnersByContractAddress(arg.chainId, arg.contractAddress)

    if not response.error.isNil:
      raise newException(ValueError, "Error getCollectibleOwnersByContractAddress" & response.error.message)

    let output = %* {
      "chainId": arg.chainId,
      "contractAddress": arg.contractAddress,
      "communityId": arg.communityId,
      "result": response.result,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "chainId": arg.chainId,
      "contractAddress": arg.contractAddress,
      "communityId": arg.communityId,
      "result": "",
      "error": e.msg
    }
    arg.finish(output)