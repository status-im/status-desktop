import stint, Tables
include ../../common/json_utils
import ../../../backend/eth
import ../../../backend/community_tokens
import ../../../backend/collectibles
import ../../../app/core/tasks/common
import ../../../app/core/tasks/qt
import ../transaction/dto
import ../community/dto/community

proc tableToJsonArray[A, B](t: var Table[A, B]): JsonNode =
  let data = newJArray()
  for k,v in t:
    data.elems.add(%*{
             "key": k,
             "value": v
    })
  return data

type
  AsyncDeployOwnerContractsFeesArg = ref object of QObjectTaskArg
    chainId: int
    addressFrom: string
    requestId: string

const asyncGetDeployOwnerContractsFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncDeployOwnerContractsFeesArg](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let response = eth.suggestedFees(arg.chainId).result
    feeTable[arg.chainId] = response.toSuggestedFeesDto()
    let deployGas = community_tokens.deployOwnerTokenEstimate().result.getInt
    gasTable[(arg.chainId, "")] = deployGas
    arg.finish(%* {
      "feeTable": tableToJsonArray(feeTable),
      "gasTable": tableToJsonArray(gasTable),
      "chainId": arg.chainId,
      "addressFrom": arg.addressFrom,
      "error": "",
      "requestId": arg.requestId,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "requestId": arg.requestId,
    })

type
  AsyncGetDeployFeesArg = ref object of QObjectTaskArg
    chainId: int
    addressFrom: string
    tokenType: TokenType
    requestId: string

const asyncGetDeployFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetDeployFeesArg](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let response = eth.suggestedFees(arg.chainId).result
    feeTable[arg.chainId] = response.toSuggestedFeesDto()
    let deployGas = if arg.tokenType == TokenType.ERC721: community_tokens.deployCollectiblesEstimate().result.getInt
      else: community_tokens.deployAssetsEstimate().result.getInt
    
    gasTable[(arg.chainId, "")] = deployGas
    arg.finish(%* {
      "feeTable": tableToJsonArray(feeTable),
      "gasTable": tableToJsonArray(gasTable),
      "chainId": arg.chainId,
      "addressFrom": arg.addressFrom,
      "error": "",
      "requestId": arg.requestId,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "requestId": arg.requestId,
    })

type
  AsyncGetRemoteBurnFees = ref object of QObjectTaskArg
    chainId: int
    contractAddress: string
    tokenIds: seq[UInt256]
    addressFrom: string
    requestId: string

const asyncGetRemoteBurnFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRemoteBurnFees](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let fee = eth.suggestedFees(arg.chainId).result.toSuggestedFeesDto()
    let burnGas = community_tokens.estimateRemoteBurn(arg.chainId, arg.contractAddress, arg.addressFrom, arg.tokenIds).result.getInt
    feeTable[arg.chainId] = fee
    gasTable[(arg.chainId, arg.contractAddress)] = burnGas
    arg.finish(%* {
      "feeTable": tableToJsonArray(feeTable),
      "gasTable": tableToJsonArray(gasTable),
      "chainId": arg.chainId,
      "addressFrom": arg.addressFrom,
      "error": "",
      "requestId": arg.requestId,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "requestId": arg.requestId,
    })

type
  AsyncGetBurnFees = ref object of QObjectTaskArg
    chainId: int
    contractAddress: string
    amount: Uint256
    addressFrom: string
    requestId: string

const asyncGetBurnFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetBurnFees](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let fee = eth.suggestedFees(arg.chainId).result.toSuggestedFeesDto()
    let burnGas = community_tokens.estimateBurn(arg.chainId, arg.contractAddress, arg.addressFrom, arg.amount).result.getInt
    feeTable[arg.chainId] = fee
    gasTable[(arg.chainId, arg.contractAddress)] = burnGas
    arg.finish(%* {
      "feeTable": tableToJsonArray(feeTable),
      "gasTable": tableToJsonArray(gasTable),
      "chainId": arg.chainId,
      "addressFrom": arg.addressFrom,
      "error": "",
      "requestId": arg.requestId
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "requestId": arg.requestId,
    })

type
  AsyncGetMintFees = ref object of QObjectTaskArg
    collectiblesAndAmounts: seq[CommunityTokenAndAmount]
    walletAddresses: seq[string]
    addressFrom: string
    requestId: string

const asyncGetMintFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetMintFees](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    for collectibleAndAmount in arg.collectiblesAndAmounts:
      # get fees if we do not have for this chain yet
      let chainId = collectibleAndAmount.communityToken.chainId
      if not feeTable.hasKey(chainId):
        let feesResponse = eth.suggestedFees(chainId).result
        feeTable[chainId] = feesResponse.toSuggestedFeesDto()

      # get gas for smart contract
      let gas = community_tokens.estimateMintTokens(chainId,
        collectibleAndAmount.communityToken.address, arg.addressFrom,
        arg.walletAddresses, collectibleAndAmount.amount).result.getInt
      gasTable[(chainId, collectibleAndAmount.communityToken.address)] = gas
    arg.finish(%* {
      "feeTable": tableToJsonArray(feeTable),
      "gasTable": tableToJsonArray(gasTable),
      "addressFrom": arg.addressFrom,
      "error": "",
      "requestId": arg.requestId
    })
  except Exception as e:
    let output = %* {
      "error": e.msg,
      "requestId": arg.requestId
    }
    arg.finish(output)

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
