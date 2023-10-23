import stint, Tables
include ../../common/json_utils
import ../../../backend/eth
import ../../../backend/community_tokens
import ../../../backend/collectibles
include ../../../app/core/tasks/common
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
    ownerParams: JsonNode
    masterParams: JsonNode
    communityId: string
    signerPubKey: string

const asyncGetDeployOwnerContractsFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncDeployOwnerContractsFeesArg](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let response = eth.suggestedFees(arg.chainId).result
    feeTable[arg.chainId] = response.toSuggestedFeesDto()

    # get deployment signature
    let signatureResponse = community_tokens.createCommunityTokenDeploymentSignature(arg.chainId, arg.addressFrom, arg.communityId)
    let signature = signatureResponse.result.getStr()

    let deployGas = community_tokens.deployOwnerTokenEstimate(arg.chainId, arg.addressFrom, arg.ownerParams, arg.masterParams, signature, arg.communityId, arg.signerPubKey).result.getInt
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
  AsyncSetSignerFeesArg = ref object of QObjectTaskArg
    chainId: int
    contractAddress: string
    addressFrom: string
    newSignerPubKey: string
    requestId: string

const asyncSetSignerFeesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSetSignerFeesArg](argEncoded)
  try:
    var gasTable: Table[ContractTuple, int] # gas per contract
    var feeTable: Table[int, SuggestedFeesDto] # fees for chain
    let response = eth.suggestedFees(arg.chainId).result
    feeTable[arg.chainId] = response.toSuggestedFeesDto()
    let gasUsed = community_tokens.estimateSetSignerPubKey(arg.chainId, arg.contractAddress, arg.addressFrom, arg.newSignerPubKey).result.getInt
    gasTable[(arg.chainId, "")] = gasUsed
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

type
  GetCommunityTokensDetailsArg = ref object of QObjectTaskArg
    communityId*: string

const getCommunityTokensDetailsTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetCommunityTokensDetailsArg](argEncoded)

  try:
    proc getRemainingSupply(chainId: int, contractAddress: string): string =
      let response = tokens_backend.remainingSupply(chainId, contractAddress)
      return response.result.getStr()

    proc getPendingTransactions(): seq[TransactionDto] =
      let response = backend.getPendingTransactions().result
      if (response.kind == JArray and response.len > 0):
        return response.getElems().map(x => x.toPendingTransactionDto())

      return @[]

    proc getCommunityTokenBurnState(chainId: int, contractAddress: string): ContractTransactionStatus =
      let allPendingTransactions = getPendingTransactions()
      
      let burnTransactions = allPendingTransactions.filter(x => x.typeValue == $PendingTransactionTypeDto.BurnCommunityToken)

      for transaction in burnTransactions:
        try:
          let communityToken = toCommunityTokenDto(parseJson(transaction.additionalData))
          if communityToken.chainId == chainId and communityToken.address == contractAddress:
            return ContractTransactionStatus.InProgress
        except Exception:
          discard
      return ContractTransactionStatus.Completed

    proc getRemoteDestructedAddresses(chainId: int, contractAddress: string): seq[string] =
      let allPendingTransactions = getPendingTransactions()
      let remoteDestructTransactions = allPendingTransactions.filter(x => x.typeValue == $PendingTransactionTypeDto.RemoteDestructCollectible)
      for transaction in remoteDestructTransactions:
        let remoteDestructTransactionDetails = toRemoteDestroyTransactionDetails(parseJson(transaction.additionalData))
        if remoteDestructTransactionDetails.chainId == chainId and remoteDestructTransactionDetails.contractAddress == contractAddress:
          return remoteDestructTransactionDetails.addresses

    proc getCommunityToken(communityTokens: seq[CommunityTokenDto], chainId: int, address: string): CommunityTokenDto =
      for token in communityTokens:
        if token.chainId == chainId and token.address == address:
          return token

    proc getRemoteDestructedAmount(communityTokens: seq[CommunityTokenDto],chainId: int, contractAddress: string): string =
      let tokenType = getCommunityToken(communityTokens, chainId, contractAddress).tokenType
      if tokenType != TokenType.ERC721:
        return "0"
      let response = tokens_backend.remoteDestructedAmount(chainId, contractAddress)
      return response.result.getStr()

    proc createTokenItemJson(communityTokens: seq[CommunityTokenDto], tokenDto: CommunityTokenDto): JsonNode =
      try:
        var remainingSupply = tokenDto.supply.toString(10)
        var burnState = ContractTransactionStatus.Completed
        var remoteDestructedAddresses: seq[string] = @[]
        var destructedAmount = "0"

        if tokenDto.deployState == DeployState.Deployed:
          remainingSupply =
            if tokenDto.infiniteSupply:
              "0"
            else:
              getRemainingSupply(tokenDto.chainId, tokenDto.address)

          burnState = getCommunityTokenBurnState(tokenDto.chainId, tokenDto.address)
          remoteDestructedAddresses = getRemoteDestructedAddresses(tokenDto.chainId, tokenDto.address)
        
          destructedAmount = getRemoteDestructedAmount(communityTokens, tokenDto.chainId, tokenDto.address)

        return %* {
          "address": tokenDto.address,
          "remainingSupply": remainingSupply,
          "burnState": burnState.int,
          "remoteDestructedAddresses": %* (remoteDestructedAddresses),
          "destructedAmount": destructedAmount,
          "error": "",
        }
      except Exception as e:
        return %* {
          "error": e.msg,
        }

    let response = tokens_backend.getCommunityTokens(arg.communityId)

    if not response.error.isNil:
      raise newException(ValueError, "Error getCommunityTokens" & response.error.message)

    let communityTokens = parseCommunityTokens(response)

    let communityTokenJsonItems = communityTokens.map(proc(tokenDto: CommunityTokenDto): JsonNode =
      result = createTokenItemJson(communityTokens, tokenDto)
      if result["error"].getStr != "":
        raise newException(ValueError, "Error creating token item" & result["error"].getStr)
    )

    let output = %* {
      "communityTokensResponse": response,
      "communityTokenJsonItems": communityTokenJsonItems,
      "communityId": arg.communityId,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "communityId": arg.communityId,
      "error": e.msg
    }
    arg.finish(output)

type
  GetAllCommunityTokensArg = ref object of QObjectTaskArg

const getAllCommunityTokensTaskArg: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetAllCommunityTokensArg](argEncoded)
  try:
    let response = tokens_backend.getAllCommunityTokens()

    let output = %* {
      "response": response,
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "error": e.msg
    }
    arg.finish(output)

type
  GetOwnerTokenOwnerAddressArgs = ref object of QObjectTaskArg
    chainId*: int
    contractAddress*: string

const getOwnerTokenOwnerAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetOwnerTokenOwnerAddressArgs](argEncoded)
  try:
    let response = tokens_backend.getOwnerTokenOwnerAddress(arg.chainId, arg.contractAddress)
    let output = %* {
      "chainId": arg.chainId,
      "contractAddress": arg.contractAddress,
      "address": response.result.getStr(),
      "error": ""
    }
    arg.finish(output)
  except Exception as e:
    let output = %* {
      "chainId": arg.chainId,
      "contractAddress": arg.contractAddress,
      "error": e.msg
    }
    arg.finish(output)