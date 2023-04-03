import NimQml, Tables, chronicles, json, stint, strutils, strformat
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/modules/shared_models/currency_amount

import ../../../backend/community_tokens as tokens_backend
import ../transaction/service as transaction_service
import ../token/service as token_service
import ../settings/service as settings_service
import ../wallet_account/service as wallet_account_service
import ../ens/utils as ens_utils
import ../eth/dto/transaction

import ../../../backend/response_type

import ../../common/conversion
import ../community/dto/community

import ./dto/deployment_parameters
import ./dto/community_token
include async_tasks

export community_token
export deployment_parameters

logScope:
  topics = "community-tokens-service"

type
  CommunityTokenAndAmount* = object
    communityToken*: CommunityTokenDto
    amount*: int

type
  CommunityTokenDeployedStatusArgs* = ref object of Args
    communityId*: string
    contractAddress*: string
    deployState*: DeployState

type
  CommunityTokenDeployedArgs* = ref object of Args
    communityToken*: CommunityTokenDto

type
  ComputeFeeErrorCode* {.pure.} = enum
    Success,
    Infura,
    Balance,
    Other

type
  ComputeDeployFeeArgs* = ref object of Args
    ethCurrency*: CurrencyAmount
    fiatCurrency*: CurrencyAmount
    errorCode*: ComputeFeeErrorCode

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS* = "communityTokenDeployStatus"
const SIGNAL_COMMUNITY_TOKEN_DEPLOYED* = "communityTokenDeployed"
const SIGNAL_COMPUTE_DEPLOY_FEE* = "computeDeployFee"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      transactionService: transaction_service.Service
      tokenService: token_service.Service
      settingsService: settings_service.Service
      walletAccountService: wallet_account_service.Service
      tempAccountAddress: string
      tempChainId: int

  proc delete*(self: Service) =
      self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    transactionService: transaction_service.Service,
    tokenService: token_service.Service,
    settingsService: settings_service.Service,
    walletAccountService: wallet_account_service.Service
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.transactionService = transactionService
    result.tokenService = tokenService
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService

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

  proc deployCollectiblesEstimate*(self: Service): int =
    try:
      let response = tokens_backend.deployCollectiblesEstimate()
      return response.result.getInt()
    except RpcException:
      error "Error getting deploy estimate", message = getCurrentExceptionMsg()

  proc deployCollectibles*(self: Service, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, chainId: int) =
    try:
      # TODO this will come from SendModal
      let suggestedFees = self.transactionService.suggestedFees(chainId)
      let contractGasUnits = self.deployCollectiblesEstimate()
      if suggestedFees == nil:
        error "Error deploying collectibles", message = "Can't get suggested fees"
        return

      let txData = ens_utils.buildTransaction(parseAddress(addressFrom), 0.u256, $contractGasUnits,
        if suggestedFees.eip1559Enabled: "" else: $suggestedFees.gasPrice, suggestedFees.eip1559Enabled,
        if suggestedFees.eip1559Enabled: $suggestedFees.maxPriorityFeePerGas else: "",
        if suggestedFees.eip1559Enabled: $suggestedFees.maxFeePerGasM else: "")

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
      communityToken.description = tokenMetadata.description
      communityToken.supply = deploymentParams.supply
      communityToken.infiniteSupply = deploymentParams.infiniteSupply
      communityToken.transferable = deploymentParams.transferable
      communityToken.remoteSelfDestruct = deploymentParams.remoteSelfDestruct
      communityToken.tokenUri = deploymentParams.tokenUri
      communityToken.chainId = chainId
      communityToken.deployState = DeployState.InProgress
      communityToken.image = tokenMetadata.image

      # save token to db
      let communityTokenJson = tokens_backend.addCommunityToken(communityToken)
      communityToken = communityTokenJson.result.toCommunityTokenDto()
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
      error "Error deploying collectibles", message = getCurrentExceptionMsg()

  proc getCommunityTokens*(self: Service, communityId: string): seq[CommunityTokenDto] =
    try:
      let response = tokens_backend.getCommunityTokens(communityId)
      return parseCommunityTokens(response)
    except RpcException:
        error "Error getting community tokens", message = getCurrentExceptionMsg()

  proc getCommunityTokenBySymbol*(self: Service, communityId: string, symbol: string): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.symbol == symbol:
        return token

  proc contractOwner*(self: Service, chainId: int, contractAddress: string): string =
    try:
      let response = tokens_backend.contractOwner(chainId, contractAddress)
      return response.result.getStr()
    except RpcException:
      error "Error getting contract owner", message = getCurrentExceptionMsg()

  proc airdropCollectibles*(self: Service, communityId: string, password: string, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string]) =
    try:
      for collectibleAndAmount in collectiblesAndAmounts:
        let addressFrom = self.contractOwner(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        let txData = TransactionDataDto(source: parseAddress(addressFrom)) #TODO estimate fee in UI
        let response = tokens_backend.mintTo(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address, %txData, password, walletAddresses, collectibleAndAmount.amount)
        echo "!!! Transaction hash ", response.result.getStr()
    except RpcException:
      error "Error minting collectibles", message = getCurrentExceptionMsg()

  proc getFiatValue*(self: Service, cryptoBalance: float, cryptoSymbol: string): float =
    if (cryptoSymbol == ""):
      return 0.0
    let currentCurrency = self.settingsService.getCurrency()
    let price = self.tokenService.getTokenPrice(cryptoSymbol, currentCurrency)
    return cryptoBalance * price

  proc computeDeployFee*(self: Service, chainId: int, accountAddress: string) =
    try:
      self.tempAccountAddress = accountAddress
      self.tempChainId = chainId
      let arg = AsyncGetSuggestedFees(
        tptr: cast[ByteAddress](asyncGetSuggestedFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onSuggestedFees",
        chainId: chainId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading fees", msg = e.msg

  proc onSuggestedFees*(self:Service, response: string) {.slot.} =
    let responseJson = response.parseJson()

    if responseJson{"error"}.kind != JNull and responseJson{"error"}.getStr != "":
        let errorMessage = responseJson["error"].getStr
        var errorCode = ComputeFeeErrorCode.Other
        if errorMessage.contains("403 Forbidden") or errorMessage.contains("exceed"):
          errorCode = ComputeFeeErrorCode.Infura
        let ethCurrency = newCurrencyAmount(0.0, "ETH", 1, false)
        let fiatCurrency = newCurrencyAmount(0.0, self.settingsService.getCurrency(), 1, false)
        let data = ComputeDeployFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode)
        self.events.emit(SIGNAL_COMPUTE_DEPLOY_FEE, data)
        return

    let suggestedFees = decodeSuggestedFeesDto(responseJson["fees"])
    let contractGasUnits = self.deployCollectiblesEstimate()
    let maxFees = suggestedFees.maxFeePerGasM
    let gasPrice = if suggestedFees.eip1559Enabled: maxFees else: suggestedFees.gasPrice

    const ethSymbol = "ETH"

    let weiValue = gwei2Wei(gasPrice) * contractGasUnits.u256
    let ethValueStr = wei2Eth(weiValue)
    let ethValue = parseFloat(ethValueStr)
    let fiatValue = self.getFiatValue(ethValue, ethSymbol)

    let wallet = self.walletAccountService.getAccountByAddress(self.tempAccountAddress)
    let balance = wallet.getCurrencyBalance(@[self.tempChainId], ethSymbol)

    let ethCurrency = newCurrencyAmount(ethValue, "ETH", 4, false)
    let fiatCurrency = newCurrencyAmount(fiatValue, self.settingsService.getCurrency(), 2, false)

    let data = ComputeDeployFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency,
                                    errorCode: (if ethValue > balance: ComputeFeeErrorCode.Balance else: ComputeFeeErrorCode.Success))
    self.events.emit(SIGNAL_COMPUTE_DEPLOY_FEE, data)
