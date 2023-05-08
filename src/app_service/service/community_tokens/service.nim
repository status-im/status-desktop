import NimQml, Tables, chronicles, json, stint, strutils
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
import ../collectible/dto as collectibles_dto

import ../../../backend/response_type

import ../../common/conversion
import ../community/dto/community

import ./dto/deployment_parameters
import ./dto/community_token
import ./dto/community_token_owner

import airdrop_details

include async_tasks

export community_token
export deployment_parameters
export community_token_owner

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
    chainId*: int
    transactionHash*: string
    deployState*: DeployState

type
  CommunityTokenDeployedArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string

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

type
  ContractTuple = tuple
    address: string
    chainId: int

type
  CommunityTokenOwnersArgs* =  ref object of Args
    communityId*: string
    contractAddress*: string
    chainId*: int
    owners*: seq[CollectibleOwner]

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS* = "communityTokenDeployStatus"
const SIGNAL_COMMUNITY_TOKEN_DEPLOYED* = "communityTokenDeployed"
const SIGNAL_COMPUTE_DEPLOY_FEE* = "computeDeployFee"
const SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED* = "communityTokenOwnersFetched"

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
      addressAndTxMap: Table[ContractTuple, string]
      tokenOwnersTimer: QTimer
      tokenOwnersCache: Table[ContractTuple, seq[CollectibleOwner]]

  # Forward declaration
  proc fetchAllTokenOwners*(self: Service)

  proc delete*(self: Service) =
      delete(self.tokenOwnersTimer)
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
    result.addressAndTxMap = initTable[ContractTuple, string]()
    result.tokenOwnersTimer = newQTimer()
    result.tokenOwnersTimer.setInterval(10*60*1000)
    signalConnect(result.tokenOwnersTimer, "timeout()", result, "onRefreshTransferableTokenOwners()", 2)

  proc init*(self: Service) =
    self.fetchAllTokenOwners()
    self.tokenOwnersTimer.start()
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
      let data = CommunityTokenDeployedStatusArgs(communityId: tokenDto.communityId, contractAddress: tokenDto.address,
                                                  deployState: deployState, chainId: tokenDto.chainId,
                                                  transactionHash: self.addressAndTxMap.getOrDefault((tokenDto.address,tokenDto.chainId)))
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)

    self.events.on(PendingTransactionTypeDto.CollectibleAirdrop.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      let airdropDetails = toAirdropDetails(parseJson(receivedData.data))
      if not receivedData.success:
        error "Collectible airdrop failed", contractAddress=airdropDetails.contractAddress
        return
      try:
        # add holders to db
        discard addTokenOwners(airdropDetails.chainId, airdropDetails.contractAddress,
                               airdropDetails.walletAddresses, airdropDetails.amount)
      except RpcException:
        error "Error adding collectible token owners", message = getCurrentExceptionMsg()

  proc deployCollectiblesEstimate*(self: Service): int =
    try:
      let response = tokens_backend.deployCollectiblesEstimate()
      return response.result.getInt()
    except RpcException:
      error "Error getting deploy estimate", message = getCurrentExceptionMsg()

  proc deployCollectibles*(self: Service, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, chainId: int) =
    try:
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
      debug "Deployed contract address ", contractAddress=contractAddress
      debug "Deployment transaction hash ", transactionHash=transactionHash

      self.addressAndTxMap[(contractAddress, chainId)] = transactionHash

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
      let data = CommunityTokenDeployedArgs(communityToken: communityToken, transactionHash: transactionHash)
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

  proc getAllCommunityTokens*(self: Service): seq[CommunityTokenDto] =
    try:
      let response = tokens_backend.getAllCommunityTokens()
      return parseCommunityTokens(response)
    except RpcException:
        error "Error getting all community tokens", message = getCurrentExceptionMsg()

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
        let transactionHash = response.result.getStr()
        debug "Airdrop transaction hash ", transactionHash=transactionHash

        let airdropDetails = AirdropDetails(
              chainId: collectibleAndAmount.communityToken.chainId,
              contractAddress: collectibleAndAmount.communityToken.address,
              walletAddresses: walletAddresses,
              amount: collectibleAndAmount.amount)

        # observe transaction state
        self.transactionService.watchTransaction(
          transactionHash,
          addressFrom,
          collectibleAndAmount.communityToken.address,
          $PendingTransactionTypeDto.CollectibleAirdrop,
          $airdropDetails.toJsonNode(),
          collectibleAndAmount.communityToken.chainId,
        )
    except RpcException:
      error "Error airdropping collectibles", message = getCurrentExceptionMsg()

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
    const ethSymbol = "ETH"

    if responseJson{"error"}.kind != JNull and responseJson{"error"}.getStr != "":
        let errorMessage = responseJson["error"].getStr
        var errorCode = ComputeFeeErrorCode.Other
        if errorMessage.contains("403 Forbidden") or errorMessage.contains("exceed"):
          errorCode = ComputeFeeErrorCode.Infura
        let ethCurrency = newCurrencyAmount(0.0, ethSymbol, 1, false)
        let fiatCurrency = newCurrencyAmount(0.0, self.settingsService.getCurrency(), 1, false)
        let data = ComputeDeployFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode)
        self.events.emit(SIGNAL_COMPUTE_DEPLOY_FEE, data)
        return

    let suggestedFees = decodeSuggestedFeesDto(responseJson["fees"])
    let contractGasUnits = self.deployCollectiblesEstimate()
    let maxFees = suggestedFees.maxFeePerGasM
    let gasPrice = if suggestedFees.eip1559Enabled: maxFees else: suggestedFees.gasPrice

    let weiValue = gwei2Wei(gasPrice) * contractGasUnits.u256
    let ethValueStr = wei2Eth(weiValue)
    let ethValue = parseFloat(ethValueStr)
    let fiatValue = self.getFiatValue(ethValue, ethSymbol)

    let wallet = self.walletAccountService.getAccountByAddress(self.tempAccountAddress)

    var balance = 0.0
    let tokens = wallet.tokens
    for token in tokens:
      if token.symbol == ethSymbol:
        balance = token.balancesPerChain[self.tempChainId].balance
        break

    let ethCurrency = newCurrencyAmount(ethValue, ethSymbol, 4, false)
    let fiatCurrency = newCurrencyAmount(fiatValue, self.settingsService.getCurrency(), 2, false)

    let data = ComputeDeployFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency,
                                    errorCode: (if ethValue > balance: ComputeFeeErrorCode.Balance else: ComputeFeeErrorCode.Success))
    self.events.emit(SIGNAL_COMPUTE_DEPLOY_FEE, data)

  proc fetchCommunityOwners*(self: Service, communityId: string, chainId: int, contractAddress: string) =
    let arg = FetchCollectibleOwnersArg(
      tptr: cast[ByteAddress](fetchCollectibleOwnersTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onCommunityTokenOwnersFetched",
      chainId: chainId,
      contractAddress: contractAddress,
      communityId: communityId
    )
    self.threadpool.start(arg)

  # get owners from cache
  proc getCommunityTokenOwners*(self: Service, communityId: string, chainId: int, contractAddress: string): seq[CollectibleOwner] =
    return self.tokenOwnersCache.getOrDefault((address: contractAddress, chainId: chainId))

  proc onCommunityTokenOwnersFetched*(self:Service, response: string) {.slot.} =
    let responseJson = response.parseJson()
    if responseJson{"error"}.kind != JNull and responseJson{"error"}.getStr != "":
      let errorMessage = responseJson["error"].getStr
      error "Can't fetch community token owners", chainId=responseJson["chainId"], contractAddress=responseJson["contractAddress"], errorMsg=errorMessage
      return
    let chainId = responseJson["chainId"].getInt
    let contractAddress = responseJson["contractAddress"].getStr
    let communityId = responseJson["communityId"].getStr
    let resultJson = responseJson["result"]
    let owners = collectibles_dto.toCollectibleOwnershipDto(resultJson).owners
    let data = CommunityTokenOwnersArgs(chainId: chainId, contractAddress: contractAddress, communityId: communityId, owners: owners)
    self.events.emit(SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED, data)

  proc onRefreshTransferableTokenOwners*(self:Service) {.slot.} =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if token.transferable:
        self.fetchCommunityOwners(token.communityId, token.chainId, token.address)

  proc fetchAllTokenOwners*(self: Service) =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      self.fetchCommunityOwners(token.communityId, token.chainId, token.address)