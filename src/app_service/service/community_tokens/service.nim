import NimQml, Tables, chronicles, json, stint, strutils, sugar, sequtils
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
import ../../common/account_constants
import ../../common/utils as common_utils
import ../community/dto/community

import ./dto/deployment_parameters
import ./dto/community_token
import ./dto/community_token_owner

export community_token
export deployment_parameters
export community_token_owner

const ethSymbol = "ETH"

type
  CommunityTokenAndAmount* = object
    communityToken*: CommunityTokenDto
    amount*: int

type
  ContractTuple* = tuple
    chainId: int
    address: string

proc `%`*(self: ContractTuple): JsonNode =
  result = %* {
    "address": self.address,
    "chainId": self.chainId
  }

proc toContractTuple*(json: JsonNode): ContractTuple =
  return (json["chainId"].getInt, json["address"].getStr)

type
  ChainWalletTuple* = tuple
    chainId: int
    address: string

include async_tasks

logScope:
  topics = "community-tokens-service"

type
  WalletAndAmount* = object
    walletAddress*: string
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
  ContractTransactionStatus* {.pure.} = enum
    Failed,
    InProgress,
    Completed

type
  RemoteDestructArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string
    status*: ContractTransactionStatus

type
  AirdropArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string
    status*: ContractTransactionStatus

type
  ComputeFeeErrorCode* {.pure.} = enum
    Success,
    Infura,
    Balance,
    Other

type
  ComputeFeeArgs* = ref object of Args
    ethCurrency*: CurrencyAmount
    fiatCurrency*: CurrencyAmount
    errorCode*: ComputeFeeErrorCode
    contractUniqueKey*: string # used for minting

proc `%`*(self: ComputeFeeArgs): JsonNode =
    result = %* {
      "ethFee": self.ethCurrency.toJsonNode(),
      "fiatFee": self.fiatCurrency.toJsonNode(),
      "errorCode": self.errorCode.int,
      "contractUniqueKey": self.contractUniqueKey,
    }

proc computeFeeArgsToJsonArray(args: seq[ComputeFeeArgs]): JsonNode =
  let arr = newJArray()
  for arg in args:
    arr.elems.add(%arg)
  return arr

type
  AirdropFeesArgs* = ref object of Args
    fees*: seq[ComputeFeeArgs]
    totalEthFee*: CurrencyAmount
    totalFiatFee*: CurrencyAmount
    errorCode*: ComputeFeeErrorCode

proc `%`*(self: AirdropFeesArgs): JsonNode =
    result = %* {
      "fees": computeFeeArgsToJsonArray(self.fees),
      "totalEthFee": self.totalEthFee.toJsonNode(),
      "totalFiatFee": self.totalFiatFee.toJsonNode(),
      "errorCode": self.errorCode.int
    }

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
const SIGNAL_COMPUTE_SELF_DESTRUCT_FEE* = "computeSelfDestructFee"
const SIGNAL_COMPUTE_BURN_FEE* = "computeBurnFee"
const SIGNAL_COMPUTE_AIRDROP_FEE* = "computeAirdropFee"
const SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED* = "communityTokenOwnersFetched"
const SIGNAL_REMOTE_DESTRUCT_STATUS* = "communityTokenRemoteDestructStatus"
const SIGNAL_BURN_STATUS* = "communityTokenBurnStatus"
const SIGNAL_AIRDROP_STATUS* = "airdropStatus"

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
      tokenOwnersTimer: QTimer
      tokenOwners1SecTimer: QTimer # used to update 1 sec after changes in owners
      tempTokenOwnersToFetch: CommunityTokenDto # used by 1sec timer
      tokenOwnersCache: Table[ContractTuple, seq[CollectibleOwner]]

      tempFeeTable: Table[int, SuggestedFeesDto] # fees per chain, filled during gas computation, used during operation (deployment, mint, burn)
      tempGasTable: Table[ContractTuple, int] # gas per contract, filled during gas computation, used during operation (deployment, mint, burn)
      tempTokensAndAmounts: seq[CommunityTokenAndAmount]

  # Forward declaration
  proc fetchAllTokenOwners*(self: Service)
  proc getCommunityTokenOwners*(self: Service, communityId: string, chainId: int, contractAddress: string): seq[CollectibleOwner]

  proc delete*(self: Service) =
      delete(self.tokenOwnersTimer)
      delete(self.tokenOwners1SecTimer)
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
    result.tokenOwnersTimer = newQTimer()
    result.tokenOwnersTimer.setInterval(10*60*1000)
    signalConnect(result.tokenOwnersTimer, "timeout()", result, "onRefreshTransferableTokenOwners()", 2)
    result.tokenOwners1SecTimer = newQTimer()
    result.tokenOwners1SecTimer.setInterval(1000)
    result.tokenOwners1SecTimer.setSingleShot(true)
    signalConnect(result.tokenOwners1SecTimer, "timeout()", result, "onFetchTempTokenOwners()", 2)

  proc init*(self: Service) =
    self.fetchAllTokenOwners()
    self.tokenOwnersTimer.start()
    self.events.on(PendingTransactionTypeDto.CollectibleDeployment.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      let deployState = if receivedData.success: DeployState.Deployed else: DeployState.Failed
      let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
      if not receivedData.success:
        error "Collectible contract not deployed", chainId=tokenDto.chainId, address=tokenDto.address
      try:
        discard updateCommunityTokenState(tokenDto.chainId, tokenDto.address, deployState) #update db state
      except RpcException:
        error "Error updating collectibles contract state", message = getCurrentExceptionMsg()
      let data = CommunityTokenDeployedStatusArgs(communityId: tokenDto.communityId, contractAddress: tokenDto.address,
                                                  deployState: deployState, chainId: tokenDto.chainId,
                                                  transactionHash: receivedData.transactionHash)
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)

    self.events.on(PendingTransactionTypeDto.CollectibleAirdrop.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
      let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
      let data = AirdropArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus)
      self.events.emit(SIGNAL_AIRDROP_STATUS, data)

      # update owners list if burn was successfull
      if receivedData.success:
        self.tempTokenOwnersToFetch = tokenDto
        self.tokenOwners1SecTimer.start()
    self.events.on(PendingTransactionTypeDto.CollectibleRemoteSelfDestruct.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
      let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
      let data = RemoteDestructArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus)
      self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)

      # update owners list if burn was successfull
      if receivedData.success:
        self.tempTokenOwnersToFetch = tokenDto
        self.tokenOwners1SecTimer.start()

    self.events.on(PendingTransactionTypeDto.CollectibleBurn.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
      let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
      if receivedData.success:
        try:
          discard updateCommunityTokenSupply(tokenDto.chainId, tokenDto.address, tokenDto.supply) #update db state
        except RpcException:
          error "Error updating collectibles supply", message = getCurrentExceptionMsg()
      let data = RemoteDestructArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus)
      self.events.emit(SIGNAL_BURN_STATUS, data)

  proc buildTransactionDataDto(self: Service, addressFrom: string, chainId: int, contractAddress: string): TransactionDataDto =
    let gasUnits = self.tempGasTable.getOrDefault((chainId, contractAddress), 0)
    let suggestedFees = self.tempFeeTable.getOrDefault(chainId, nil)
    if suggestedFees == nil:
      error "Can't find suggested fees for chainId", chainId=chainId
      return
    return ens_utils.buildTransaction(parseAddress(addressFrom), 0.u256, $gasUnits,
      if suggestedFees.eip1559Enabled: "" else: $suggestedFees.gasPrice, suggestedFees.eip1559Enabled,
      if suggestedFees.eip1559Enabled: $suggestedFees.maxPriorityFeePerGas else: "",
      if suggestedFees.eip1559Enabled: $suggestedFees.maxFeePerGasM else: "")

  proc deployCollectibles*(self: Service, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, chainId: int) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, "")
      if txData.source == parseAddress(ZERO_ADDRESS):
        return

      let response = tokens_backend.deployCollectibles(chainId, %deploymentParams, %txData, password)
      let contractAddress = response.result["contractAddress"].getStr()
      let transactionHash = response.result["transactionHash"].getStr()
      debug "Deployed contract address ", contractAddress=contractAddress
      debug "Deployment transaction hash ", transactionHash=transactionHash

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

  proc contractOwnerName*(self: Service, chainId: int, contractAddress: string): string =
    try:
      let response = tokens_backend.contractOwner(chainId, contractAddress)
      return self.walletAccountService.getAccountByAddress(response.result.getStr().toLower()).name
    except RpcException:
      error "Error getting contract owner name", message = getCurrentExceptionMsg()

  proc getRemainingSupply*(self: Service, chainId: int, contractAddress: string): int =
    try:
      let response = tokens_backend.remainingSupply(chainId, contractAddress)
      return response.result.getInt()
    except RpcException:
      error "Error getting remaining supply", message = getCurrentExceptionMsg()

  proc airdropCollectibles*(self: Service, communityId: string, password: string, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string]) =
    try:
      for collectibleAndAmount in collectiblesAndAmounts:
        let addressFrom = self.contractOwner(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        let txData = self.buildTransactionDataDto(addressFrom, collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        if txData.source == parseAddress(ZERO_ADDRESS):
          return
        debug "Airdrop collectibles ", chainId=collectibleAndAmount.communityToken.chainId, address=collectibleAndAmount.communityToken.address, amount=collectibleAndAmount.amount
        let response = tokens_backend.mintTo(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address, %txData, password, walletAddresses, collectibleAndAmount.amount)
        let transactionHash = response.result.getStr()
        debug "Airdrop transaction hash ", transactionHash=transactionHash

        var data = AirdropArgs(communityToken: collectibleAndAmount.communityToken, transactionHash: transactionHash, status: ContractTransactionStatus.InProgress)
        self.events.emit(SIGNAL_AIRDROP_STATUS, data)

        # observe transaction state
        self.transactionService.watchTransaction(
          transactionHash,
          addressFrom,
          collectibleAndAmount.communityToken.address,
          $PendingTransactionTypeDto.CollectibleAirdrop,
          $collectibleAndAmount.communityToken.toJsonNode(),
          collectibleAndAmount.communityToken.chainId,
        )
    except RpcException:
      error "Error airdropping collectibles", message = getCurrentExceptionMsg()

  proc computeAirdropCollectiblesFee*(self: Service, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string]) =
    try:
      self.tempTokensAndAmounts = collectiblesAndAmounts
      let arg = AsyncGetMintFees(
        tptr: cast[ByteAddress](asyncGetMintFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAirdropFees",
        collectiblesAndAmounts: collectiblesAndAmounts,
        walletAddresses: walletAddresses
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading airdrop fees", msg = e.msg

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
      let arg = AsyncGetDeployFeesArg(
        tptr: cast[ByteAddress](asyncGetDeployFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onDeployFees",
        chainId: chainId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading fees", msg = e.msg

  proc findContractByUniqueId*(self: Service, contractUniqueKey: string): CommunityTokenDto =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if common_utils.contractUniqueKey(token.chainId, token.address) == contractUniqueKey:
        return token

  proc getOwnerBalances(self: Service, contractOwners: seq[CollectibleOwner], ownerAddress: string): seq[CollectibleBalance] =
    for owner in contractOwners:
      if owner.address == ownerAddress:
        return owner.balances

  proc collectTokensToBurn(self: Service, walletAndAmountList: seq[WalletAndAmount], contractOwners: seq[CollectibleOwner]): seq[UInt256] =
    if len(walletAndAmountList) == 0 or len(contractOwners) == 0:
      return
    for walletAndAmount in walletAndAmountList:
      let ownerBalances = self.getOwnerBalances(contractOwners, walletAndAmount.walletAddress)
      let amount = walletAndAmount.amount
      if amount > len(ownerBalances):
        error "amount to burn is higher than the number of tokens", amount=amount, balance=len(ownerBalances), owner=walletAndAmount.walletAddress
        return
      for i in 0..amount-1: # add the amount of tokens
        result.add(ownerBalances[i].tokenId)

  proc getTokensToBurn(self: Service, walletAndAmountList: seq[WalletAndAmount], contract: CommunityTokenDto): seq[Uint256] =
    if contract.address == "":
      error "Can't find contract"
      return
    let tokenOwners = self.getCommunityTokenOwners(contract.communityId, contract.chainId, contract.address)
    let tokenIds = self.collectTokensToBurn(walletAndAmountList, tokenOwners)
    if len(tokenIds) == 0:
      error "Can't find token ids to burn"
    return tokenIds

  proc selfDestructCollectibles*(self: Service, communityId: string, password: string, walletAndAmounts: seq[WalletAndAmount], contractUniqueKey: string) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let tokenIds = self.getTokensToBurn(walletAndAmounts, contract)
      if len(tokenIds) == 0:
        return
      let addressFrom = self.contractOwner(contract.chainId, contract.address)
      let txData = self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Remote destruct collectibles ", chainId=contract.chainId, address=contract.address, tokens=tokenIds
      let response = tokens_backend.remoteBurn(contract.chainId, contract.address, %txData, password, tokenIds)
      let transactionHash = response.result.getStr()
      debug "Remote destruct transaction hash ", transactionHash=transactionHash

      var data = RemoteDestructArgs(communityToken: contract, transactionHash: transactionHash, status: ContractTransactionStatus.InProgress)
      self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)

      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contract.address,
        $PendingTransactionTypeDto.CollectibleRemoteSelfDestruct,
        $contract.toJsonNode(),
        contract.chainId,
      )
    except Exception as e:
      error "Remote self destruct error", msg = e.msg

  proc computeSelfDestructFee*(self: Service, walletAndAmountList: seq[WalletAndAmount], contractUniqueKey: string) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      self.tempAccountAddress = self.contractOwner(contract.chainId, contract.address)
      self.tempChainId = contract.chainId
      let tokenIds = self.getTokensToBurn(walletAndAmountList, contract)
      if len(tokenIds) == 0:
        warn "token list is empty"
        return
      let arg = AsyncGetRemoteBurnFees(
        tptr: cast[ByteAddress](asyncGetRemoteBurnFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onSelfDestructFees",
        chainId: contract.chainId,
        contractAddress: contract.address,
        tokenIds: tokenIds
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading fees", msg = e.msg

  proc create0CurrencyAmounts(self: Service): (CurrencyAmount, CurrencyAmount) =
    let ethCurrency = newCurrencyAmount(0.0, ethSymbol, 1, false)
    let fiatCurrency = newCurrencyAmount(0.0, self.settingsService.getCurrency(), 1, false)
    return (ethCurrency, fiatCurrency)

  proc createCurrencyAmounts(self: Service, ethValue: float64, fiatValue: float64): (CurrencyAmount, CurrencyAmount) =
    let ethCurrency = newCurrencyAmount(ethValue, ethSymbol, 4, false)
    let fiatCurrency = newCurrencyAmount(fiatValue, self.settingsService.getCurrency(), 2, false)
    return (ethCurrency, fiatCurrency)

  proc getErrorCodeFromMessage(self: Service, errorMessage: string): ComputeFeeErrorCode =
    var errorCode = ComputeFeeErrorCode.Other
    if errorMessage.contains("403 Forbidden") or errorMessage.contains("exceed"):
      errorCode = ComputeFeeErrorCode.Infura
    return errorCode

  proc burnCollectibles*(self: Service, communityId: string, password: string, contractUniqueKey: string, amount: int) =
    try:
      var contract = self.findContractByUniqueId(contractUniqueKey)
      let addressFrom = self.contractOwner(contract.chainId, contract.address)
      let txData = self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Burn collectibles ", chainId=contract.chainId, address=contract.address, amount=amount
      let response = tokens_backend.burn(contract.chainId, contract.address, %txData, password, amount)
      let transactionHash = response.result.getStr()
      debug "Burn transaction hash ", transactionHash=transactionHash

      var data = RemoteDestructArgs(communityToken: contract, transactionHash: transactionHash, status: ContractTransactionStatus.InProgress)
      self.events.emit(SIGNAL_BURN_STATUS, data)

      contract.supply = contract.supply - amount # save with changed supply
      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contract.address,
        $PendingTransactionTypeDto.CollectibleBurn,
        $contract.toJsonNode(),
        contract.chainId,
      )
    except Exception as e:
      error "Burn error", msg = e.msg

  proc computeBurnFee*(self: Service, contractUniqueKey: string, amount: int) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      self.tempAccountAddress = self.contractOwner(contract.chainId, contract.address)
      self.tempChainId = contract.chainId
      let arg = AsyncGetBurnFees(
        tptr: cast[ByteAddress](asyncGetBurnFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onBurnFees",
        chainId: contract.chainId,
        contractAddress: contract.address,
        amount: amount
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading fees", msg = e.msg

  proc createComputeFeeArgsWithError(self:Service, errorMessage: string): ComputeFeeArgs =
    let errorCode = self.getErrorCodeFromMessage(errorMessage)
    let (ethCurrency, fiatCurrency) = self.create0CurrencyAmounts()
    return ComputeFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode)

  proc computeEthValue(self:Service, gasUnits: int, suggestedFees: SuggestedFeesDto): float =
    try:
      let maxFees = suggestedFees.maxFeePerGasM
      let gasPrice = if suggestedFees.eip1559Enabled: maxFees else: suggestedFees.gasPrice

      let weiValue = gwei2Wei(gasPrice) * gasUnits.u256
      let ethValueStr = wei2Eth(weiValue)
      return parseFloat(ethValueStr)
    except Exception as e:
      error "Error computing eth value", msg = e.msg

  proc getWalletBalanceForChain(self:Service, walletAddress: string, chainId: int): float =
    let wallet = self.walletAccountService.getAccountByAddress(walletAddress.toLower())
    var balance = 0.0
    let tokens = wallet.tokens
    for token in tokens:
      if token.symbol == ethSymbol:
        balance = token.balancesPerChain[chainId].balance
        break
    return balance

  proc createComputeFeeArgsFromEthAndBalance(self: Service, ethValue: float, balance: float): ComputeFeeArgs =
    let fiatValue = self.getFiatValue(ethValue, ethSymbol)
    let (ethCurrency, fiatCurrency) = self.createCurrencyAmounts(ethValue, fiatValue)
    return ComputeFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency,
                                    errorCode: (if ethValue > balance: ComputeFeeErrorCode.Balance else: ComputeFeeErrorCode.Success))

  proc createComputeFeeArgs(self: Service, gasUnits: int, suggestedFees: SuggestedFeesDto, chainId: int, walletAddress: string): ComputeFeeArgs =
    let ethValue = self.computeEthValue(gasUnits, suggestedFees)
    let balance = self.getWalletBalanceForChain(walletAddress, chainId)
    return self.createComputeFeeArgsFromEthAndBalance(ethValue, balance)

  # convert json returned from async task into gas table
  proc toGasTable(json: JsonNode): Table[ContractTuple, int] =
    try:
      if json.kind != JArray:
        return
      for i in json:
        result[i["key"].toContractTuple] = i["value"].getInt
    except Exception:
      error "Error converting to gas table", message = getCurrentExceptionMsg()

  # convert json returned from async task into fee table
  proc toFeeTable(json: JsonNode): Table[int, SuggestedFeesDto] =
    try:
      if json.kind != JArray:
        return
      for i in json:
        result[i["key"].getInt] = decodeSuggestedFeesDto(i["value"])
    except Exception:
      error "Error converting to fee table", message = getCurrentExceptionMsg()

  proc parseFeeResponseAndEmitSignal(self:Service, response: string, signalName: string) =
    try:
      let responseJson = response.parseJson()
      let errorMessage = responseJson{"error"}.getStr
      if errorMessage != "":
        let data = self.createComputeFeeArgsWithError(errorMessage)
        self.events.emit(signalName, data)
        return
      let gasTable = responseJson{"gasTable"}.toGasTable
      let feeTable = responseJson{"feeTable"}.toFeeTable
      self.tempGasTable = gasTable
      self.tempFeeTable = feeTable
      let gasUnits = toSeq(gasTable.values())[0]
      let suggestedFees = toSeq(feeTable.values())[0]
      let data = self.createComputeFeeArgs(gasUnits, suggestedFees, self.tempChainId, self.tempAccountAddress)
      self.events.emit(signalName, data)
    except Exception:
      error "Error creating self destruct fee args", message = getCurrentExceptionMsg()
      let data = self.createComputeFeeArgsWithError(getCurrentExceptionMsg())
      self.events.emit(signalName, data)

  proc onSelfDestructFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_SELF_DESTRUCT_FEE)

  proc onBurnFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_BURN_FEE)

  proc onDeployFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_DEPLOY_FEE)

  proc onAirdropFees*(self:Service, response: string) {.slot.} =
    var wholeEthCostForChainWallet: Table[ChainWalletTuple, float]
    var ethValuesForContracts: Table[ContractTuple, float]
    var allComputeFeeArgs: seq[ComputeFeeArgs]
    var dataToEmit = AirdropFeesArgs()
    dataToEmit.errorCode =  ComputeFeeErrorCode.Success

    try:
      let responseJson = response.parseJson()
      let errorMessage = responseJson{"error"}.getStr
      if errorMessage != "":
        for collectibleAndAmount in self.tempTokensAndAmounts:
          let args = self.createComputeFeeArgsWithError(errorMessage)
          args.contractUniqueKey = common_utils.contractUniqueKey(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
          dataToEmit.fees.add(args)
        let (ethTotal, fiatTotal) = self.create0CurrencyAmounts()
        dataToEmit.totalEthFee = ethTotal
        dataToEmit.totalFiatFee = fiatTotal
        dataToEmit.errorCode = self.getErrorCodeFromMessage(errorMessage)
        self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)
        return

      let gasTable = responseJson{"gasTable"}.toGasTable
      let feeTable = responseJson{"feeTable"}.toFeeTable
      self.tempGasTable = gasTable
      self.tempFeeTable = feeTable

      # compute eth cost for every contract
      # also sum all eth costs per (chain, wallet) - it will be needed to compare with (chain, wallet) balance
      for collectibleAndAmount in self.tempTokensAndAmounts:
        let gasUnits = self.tempGasTable[(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)]
        let suggestedFees = self.tempFeeTable[collectibleAndAmount.communityToken.chainId]
        let ethValue = self.computeEthValue(gasUnits, suggestedFees)
        let walletAddress = self.contractOwner(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        wholeEthCostForChainWallet[(collectibleAndAmount.communityToken.chainId, walletAddress)] = wholeEthCostForChainWallet.getOrDefault((collectibleAndAmount.communityToken.chainId, walletAddress), 0.0) + ethValue
        ethValuesForContracts[(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)] = ethValue

      var totalEthVal = 0.0
      var totalFiatVal = 0.0
      # for every contract create cost Args
      for collectibleAndAmount in self.tempTokensAndAmounts:
        let contractTuple = (chainId: collectibleAndAmount.communityToken.chainId,
                                          address: collectibleAndAmount.communityToken.address)
        let ethValue = ethValuesForContracts[contractTuple]
        let walletAddress = self.contractOwner(contractTuple.chainId, contractTuple.address)
        var balance = self.getWalletBalanceForChain(walletAddress, contractTuple.chainId)
        if balance < wholeEthCostForChainWallet[(contractTuple.chainId, walletAddress)]:
          # if wallet balance for this chain is less than the whole cost
          # then we can't afford it; setting balance to 0.0 will set balance error code in Args
          balance = 0.0
          dataToEmit.errorCode = ComputeFeeErrorCode.Balance # set total error code to balance error
        var args = self.createComputeFeeArgsFromEthAndBalance(ethValue, balance)
        totalEthVal = totalEthVal + ethValue
        totalFiatVal = totalFiatVal + args.fiatCurrency.getAmountFloat()
        args.contractUniqueKey = common_utils.contractUniqueKey(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        allComputeFeeArgs.add(args)

      dataToEmit.fees = allComputeFeeArgs
      let (ethTotal, fiatTotal) = self.createCurrencyAmounts(totalEthVal, totalFiatVal)
      dataToEmit.totalEthFee = ethTotal
      dataToEmit.totalFiatFee = fiatTotal
      self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)

    except Exception as e:
      error "Error computing airdrop fees", msg = e.msg

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
    return self.tokenOwnersCache.getOrDefault((chainId: chainId, address: contractAddress))

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
    var owners = collectibles_dto.toCollectibleOwnershipDto(resultJson).owners
    owners = owners.filter(x => x.address != ZERO_ADDRESS)
    self.tokenOwnersCache[(chainId, contractAddress)] = owners
    let data = CommunityTokenOwnersArgs(chainId: chainId, contractAddress: contractAddress, communityId: communityId, owners: owners)
    self.events.emit(SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED, data)

  proc onRefreshTransferableTokenOwners*(self:Service) {.slot.} =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if token.transferable:
        self.fetchCommunityOwners(token.communityId, token.chainId, token.address)

  proc onFetchTempTokenOwners*(self: Service) {.slot.} =
    self.fetchCommunityOwners(self.tempTokenOwnersToFetch.communityId, self.tempTokenOwnersToFetch.chainId, self.tempTokenOwnersToFetch.address)

  proc fetchAllTokenOwners*(self: Service) =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      self.fetchCommunityOwners(token.communityId, token.chainId, token.address)