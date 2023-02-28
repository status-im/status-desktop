import NimQml, Tables, chronicles, json, stint
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/community_tokens as tokens_backend
import ../network/service as network_service
import ../transaction/service as transaction_service

import ../eth/dto/transaction

import ../../../backend/response_type

import ../../common/conversion

import ./dto/deployment_parameters
import ./dto/community_token

export community_token
export deployment_parameters

logScope:
  topics = "community-tokens-service"

type
  CommunityTokenDeployedStatusArgs* = ref object of Args
    communityId*: string
    contractAddress*: string
    deployState*: DeployState

type
  CommunityTokenDeployedArgs* = ref object of Args
    communityToken*: CommunityTokenDto

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS* = "communityTokenDeployStatus"
const SIGNAL_COMMUNITY_TOKEN_DEPLOYED* = "communityTokenDeployed"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      networkService: network_service.Service
      transactionService: transaction_service.Service

  proc delete*(self: Service) =
      self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
    transactionService: transaction_service.Service
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.transactionService = transactionService

  proc init*(self: Service) =
    self.events.on(PendingTransactionTypeDto.CollectibleDeployment.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      let deployState = if receivedData.success: DeployState.Deployed else: DeployState.Failed
      let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
      if not receivedData.success:
        error "Collectible contract not deployed", address=tokenDto.address
      try:
        discard updateCommunityTokenState(tokenDto.address, deployState) #update db state
      except RpcException:
        error "Error updating collectibles contract state", message = getCurrentExceptionMsg()
      let data = CommunityTokenDeployedStatusArgs(communityId: tokenDto.communityId, contractAddress: tokenDto.address, deployState: deployState)
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)

  proc mintCollectibles*(self: Service, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters) =
    try:
      let chainId = self.networkService.getNetworkForCollectibles().chainId
      let txData = TransactionDataDto(source: parseAddress(addressFrom))

      let response = tokens_backend.deployCollectibles(chainId, %deploymentParams, %txData, password)
      let contractAddress = response.result["contractAddress"].getStr()
      let transactionHash = response.result["transactionHash"].getStr()
      echo "!!! Contract address ", contractAddress
      echo "!!! Transaction hash ", transactionHash

      var communityToken: CommunityTokenDto
      communityToken.tokenType = TokenType.ERC721
      communityToken.communityId = communityId
      communityToken.address = contractAddress
      communityToken.name = deploymentParams.name
      communityToken.symbol = deploymentParams.symbol
      communityToken.description = deploymentParams.description
      communityToken.supply = deploymentParams.supply
      communityToken.infiniteSupply = deploymentParams.infiniteSupply
      communityToken.transferable = deploymentParams.transferable
      communityToken.remoteSelfDestruct = deploymentParams.remoteSelfDestruct
      communityToken.tokenUri = deploymentParams.tokenUri
      communityToken.chainId = chainId
      communityToken.deployState = DeployState.InProgress
      communityToken.image = "" # TODO later

      # save token to db
      discard tokens_backend.addCommunityToken(communityToken)
      let data = CommunityTokenDeployedArgs(communityToken: communityToken)
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOYED, data)

      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contractAddress,
        $PendingTransactionTypeDto.CollectibleDeployment,
        $communityToken.toJsonNode(),
        chainId,
      )

    except RpcException:
      error "Error minting collectibles", message = getCurrentExceptionMsg()

  proc getCommunityTokens*(self: Service, communityId: string): seq[CommunityTokenDto] =
    try:
      let chainId = self.networkService.getNetworkForCollectibles().chainId
      let response = tokens_backend.getCommunityTokens(communityId, chainId)
      return parseCommunityTokens(response)
    except RpcException:
        error "Error getting community tokens", message = getCurrentExceptionMsg()

  proc getCommunityTokenBySymbol*(self: Service, communityId: string, symbol: string): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.symbol == symbol:
        return token

