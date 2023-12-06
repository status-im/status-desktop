import NimQml, Tables, chronicles, json, stint, strutils, sugar, sequtils
import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types

import ../../../app/modules/shared_models/currency_amount

import ../../../backend/collectibles as collectibles_backend
import ../../../backend/communities as communities_backend
import ../../../backend/community_tokens as tokens_backend
import ../transaction/service as transaction_service
import ../token/service as token_service
import ../settings/service as settings_service
import ../wallet_account/service as wallet_account_service
import ../activity_center/service as ac_service
import ../community/service as community_service
import ../ens/utils as ens_utils
import ../eth/dto/transaction
from backend/collectibles_types import CollectibleOwner
import ../../../backend/backend

import ../../../backend/response_type

import ../../common/activity_center
import ../../common/conversion
import ../../common/account_constants
import ../../common/utils as common_utils
import ../community/dto/community
import ../contacts/dto/contacts

import ./community_collectible_owner
import ./dto/deployment_parameters
import ./dto/community_token
import ./dto/community_token_owner

export community_token
export deployment_parameters
export community_token_owner

const ethSymbol = "ETH"

include async_tasks

logScope:
  topics = "community-tokens-service"

type
  CommunityTokenDeployedStatusArgs* = ref object of Args
    communityId*: string
    contractAddress*: string
    chainId*: int
    transactionHash*: string
    deployState*: DeployState

type
  OwnerTokenDeployedStatusArgs* = ref object of Args
    communityId*: string
    chainId*: int
    ownerContractAddress*: string
    masterContractAddress*: string
    transactionHash*: string
    deployState*: DeployState

type
  CommunityTokensArgs* = ref object of Args
    communityTokens*: seq[CommunityTokenDto]

type
  CommunityTokenDeploymentArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string

type
  OwnerTokenDeploymentArgs* = ref object of Args
    ownerToken*: CommunityTokenDto
    masterToken*: CommunityTokenDto
    transactionHash*: string

type
  CommunityTokenRemovedArgs* = ref object of Args
    communityId*: string
    contractAddress*: string
    chainId*: int

type
  OwnerTokenOwnerAddressArgs* = ref object of Args
    chainId*: int
    contractAddress*: string
    address*: string
    addressName*: string

type
  RemoteDestructArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string
    status*: ContractTransactionStatus
    remoteDestructAddresses*: seq[string]

type
  AirdropArgs* = ref object of Args
    communityToken*: CommunityTokenDto
    transactionHash*: string
    status*: ContractTransactionStatus

type
  ComputeFeeArgs* = ref object of Args
    ethCurrency*: CurrencyAmount
    fiatCurrency*: CurrencyAmount
    errorCode*: ComputeFeeErrorCode
    contractUniqueKey*: string # used for minting
    requestId*: string

type
  SetSignerArgs* = ref object of Args
    transactionHash*: string
    status*: ContractTransactionStatus
    communityId*: string
    chainId*: int

proc `%`*(self: ComputeFeeArgs): JsonNode =
    result = %* {
      "ethFee": if self.ethCurrency == nil: newCurrencyAmount().toJsonNode() else: self.ethCurrency.toJsonNode(),
      "fiatFee": if self.fiatCurrency == nil: newCurrencyAmount().toJsonNode() else: self.fiatCurrency.toJsonNode(),
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
    requestId*: string

proc `%`*(self: AirdropFeesArgs): JsonNode =
    result = %* {
      "fees": computeFeeArgsToJsonArray(self.fees),
      "totalEthFee": if self.totalEthFee == nil: newCurrencyAmount().toJsonNode() else: self.totalEthFee.toJsonNode(),
      "totalFiatFee": if self.totalFiatFee == nil: newCurrencyAmount().toJsonNode() else: self.totalFiatFee.toJsonNode(),
      "errorCode": self.errorCode.int,
      "requestId": self.requestId,
    }

type
  CommunityTokenOwnersArgs* =  ref object of Args
    communityId*: string
    contractAddress*: string
    chainId*: int
    owners*: seq[CommunityCollectibleOwner]

type
  CommunityTokensDetailsArgs* =  ref object of Args
    communityId*: string
    communityTokens*: seq[CommunityTokenDto]
    communityTokenJsonItems*: JsonNode

type
  OwnerTokenReceivedArgs* =  ref object of Args
    communityId*: string
    communityName*: string
    chainId*: int
    contractAddress*: string

type
  FinaliseOwnershipStatusArgs* =  ref object of Args
    isPending*: bool
    communityId*: string

type ContractDetails* = object
  chainId*: int
  contractAddress*: string
  communityId*: string

proc `%`*(self: ContractDetails): JsonNode =
  result = %* {
    "chainId": self.chainId,
    "contractAddress": self.contractAddress,
    "communityId": self.communityId,
  }

proc toContractDetails*(jsonObj: JsonNode): ContractDetails =
  result = ContractDetails()
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("communityId", result.communityId)

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS* = "communityTokens-communityTokenDeployStatus"
const SIGNAL_COMMUNITY_TOKEN_DEPLOYMENT_STARTED* = "communityTokens-communityTokenDeploymentStarted"
const SIGNAL_COMPUTE_DEPLOY_FEE* = "communityTokens-computeDeployFee"
const SIGNAL_COMPUTE_SET_SIGNER_FEE* = "communityTokens-computeSetSignerFee"
const SIGNAL_COMPUTE_SELF_DESTRUCT_FEE* = "communityTokens-computeSelfDestructFee"
const SIGNAL_COMPUTE_BURN_FEE* = "communityTokens-computeBurnFee"
const SIGNAL_COMPUTE_AIRDROP_FEE* = "communityTokens-computeAirdropFee"
const SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED* = "communityTokens-communityTokenOwnersFetched"
const SIGNAL_REMOTE_DESTRUCT_STATUS* = "communityTokens-communityTokenRemoteDestructStatus"
const SIGNAL_BURN_STATUS* = "communityTokens-communityTokenBurnStatus"
const SIGNAL_AIRDROP_STATUS* = "communityTokens-airdropStatus"
const SIGNAL_REMOVE_COMMUNITY_TOKEN_FAILED* = "communityTokens-removeCommunityTokenFailed"
const SIGNAL_COMMUNITY_TOKEN_REMOVED* = "communityTokens-communityTokenRemoved"
const SIGNAL_OWNER_TOKEN_DEPLOY_STATUS* = "communityTokens-ownerTokenDeployStatus"
const SIGNAL_OWNER_TOKEN_DEPLOYMENT_STARTED* = "communityTokens-ownerTokenDeploymentStarted"
const SIGNAL_COMMUNITY_TOKENS_DETAILS_LOADED* = "communityTokens-communityTokenDetailsLoaded"
const SIGNAL_ALL_COMMUNITY_TOKENS_LOADED* = "communityTokens-allCommunityTokensLoaded"
const SIGNAL_OWNER_TOKEN_RECEIVED* = "communityTokens-ownerTokenReceived"
const SIGNAL_SET_SIGNER_STATUS* = "communityTokens-setSignerStatus"
const SIGNAL_FINALISE_OWNERSHIP_STATUS* = "communityTokens-finaliseOwnershipStatus"
const SIGNAL_OWNER_TOKEN_OWNER_ADDRESS* = "communityTokens-ownerTokenOwnerAddress"

QtObject:
  type
    Service* = ref object of QObject
      events: EventEmitter
      threadpool: ThreadPool
      transactionService: transaction_service.Service
      tokenService: token_service.Service
      settingsService: settings_service.Service
      walletAccountService: wallet_account_service.Service
      acService: ac_service.Service
      communityService: community_service.Service

      tokenOwnersTimer: QTimer
      tokenOwners1SecTimer: QTimer # used to update 1 sec after changes in owners
      tempTokenOwnersToFetch: CommunityTokenDto # used by 1sec timer
      tokenOwnersCache: Table[ContractTuple, seq[CommunityCollectibleOwner]]

      tempFeeTable: Table[int, SuggestedFeesDto] # fees per chain, filled during gas computation, used during operation (deployment, mint, burn)
      tempGasTable: Table[ContractTuple, int] # gas per contract, filled during gas computation, used during operation (deployment, mint, burn)
      tempTokensAndAmounts: seq[CommunityTokenAndAmount]

  # Forward declaration
  proc fetchAllTokenOwners*(self: Service)
  proc getCommunityTokenOwners*(self: Service, communityId: string, chainId: int, contractAddress: string): seq[CommunityCollectibleOwner]
  proc getCommunityToken*(self: Service, chainId: int, address: string): CommunityTokenDto
  proc findContractByUniqueId*(self: Service, contractUniqueKey: string): CommunityTokenDto

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
    walletAccountService: wallet_account_service.Service,
    acService: ac_service.Service,
    communityService: community_service.Service
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.transactionService = transactionService
    result.tokenService = tokenService
    result.settingsService = settingsService
    result.walletAccountService = walletAccountService
    result.acService = acService
    result.communityService = communityService
    result.tokenOwnersTimer = newQTimer()
    result.tokenOwnersTimer.setInterval(10*60*1000)
    signalConnect(result.tokenOwnersTimer, "timeout()", result, "onRefreshTransferableTokenOwners()", 2)
    result.tokenOwners1SecTimer = newQTimer()
    result.tokenOwners1SecTimer.setInterval(1000)
    result.tokenOwners1SecTimer.setSingleShot(true)
    signalConnect(result.tokenOwners1SecTimer, "timeout()", result, "onFetchTempTokenOwners()", 2)

  proc processReceivedCollectiblesWalletEvent(self: Service, jsonMessage: string) =
    try:
      let dataMessageJson = parseJson(jsonMessage)
      let tokenDataPayload = fromJson(dataMessageJson, CommunityCollectiblesReceivedPayload)
      for coll in tokenDataPayload.collectibles:
        if not coll.communityData.isSome():
          continue
        let id = coll.id
        let communityData = coll.communityData.get()

        let privilegesLevel = communityData.privilegesLevel
        let communityId = communityData.id
        let community = self.communityService.getCommunityById(communityId)
        if privilegesLevel == PrivilegesLevel.Owner and not community.isOwner():
          let communityName = communityData.name
          let chainId = id.contractID.chainID
          let contractAddress = id.contractID.address
          debug "received owner token", contractAddress=contractAddress, chainId=chainId
          let tokenReceivedArgs = OwnerTokenReceivedArgs(communityId: communityId, communityName: communityName, chainId: chainId, contractAddress: contractAddress)
          self.events.emit(SIGNAL_OWNER_TOKEN_RECEIVED, tokenReceivedArgs)
          let finaliseStatusArgs = FinaliseOwnershipStatusArgs(isPending: true, communityId: communityId)
          self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)

          let response = tokens_backend.registerOwnerTokenReceivedNotification(communityId)
          checkAndEmitACNotificationsFromResponse(self.events, response.result{"activityCenterNotifications"})

    except Exception as e:
      error "Error registering owner token received notification", msg=e.msg

  proc processSetSignerTransactionEvent(self: Service, transactionArgs: TransactionMinedArgs) =
    try:
      if not transactionArgs.success:
        error "Signer not set"
      let contractDetails = transactionArgs.data.parseJson().toContractDetails()
      if transactionArgs.success:
        # promoteSelfToControlNode will be moved to status-go in next phase
        discard tokens_backend.promoteSelfToControlNode(contractDetails.communityId)
        let finaliseStatusArgs = FinaliseOwnershipStatusArgs(isPending: false, communityId: contractDetails.communityId)
        self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)

      let data = SetSignerArgs(status: if transactionArgs.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed,
                              chainId: transactionArgs.chainId,
                              transactionHash: transactionArgs.transactionHash,
                              communityId: contractDetails.communityId)
      self.events.emit(SIGNAL_SET_SIGNER_STATUS, data)

      let response = if transactionArgs.success: tokens_backend.registerReceivedOwnershipNotification(contractDetails.communityId) else: tokens_backend.registerSetSignerFailedNotification(contractDetails.communityId)
      checkAndEmitACNotificationsFromResponse(self.events, response.result{"activityCenterNotifications"})

      let notificationToSetRead = self.acService.getNotificationForTypeAndCommunityId(notification.ActivityCenterNotificationType.OwnerTokenReceived, contractDetails.communityId)
      if notificationToSetRead != nil:
        self.acService.markActivityCenterNotificationRead(notificationToSetRead.id)
    except Exception as e:
      error "Error processing set signer transaction", msg=e.msg

  proc init*(self: Service) =
    self.fetchAllTokenOwners()
    self.tokenOwnersTimer.start()

    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      if data.eventType == collectibles_backend.eventCommunityCollectiblesReceived:
        self.processReceivedCollectiblesWalletEvent(data.message)

    self.events.on(PendingTransactionTypeDto.SetSignerPublicKey.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      self.processSetSignerTransactionEvent(receivedData)

    self.events.on(PendingTransactionTypeDto.DeployCommunityToken.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      try:
        let deployState = if receivedData.success: DeployState.Deployed else: DeployState.Failed
        let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
        if not receivedData.success:
          error "Community contract not deployed", chainId=tokenDto.chainId, address=tokenDto.address
        try:
          discard updateCommunityTokenState(tokenDto.chainId, tokenDto.address, deployState) #update db state
          # now add community token to community and publish update
          let response = tokens_backend.addCommunityToken(tokenDto.communityId, tokenDto.chainId, tokenDto.address)
          if response.error != nil:
            let error = Json.decode($response.error, RpcError)
            raise newException(RpcException, "error adding community token: " & error.message)
        except RpcException:
          error "Error updating community contract state", message = getCurrentExceptionMsg()
        let data = CommunityTokenDeployedStatusArgs(communityId: tokenDto.communityId, contractAddress: tokenDto.address,
                                                    deployState: deployState, chainId: tokenDto.chainId,
                                                    transactionHash: receivedData.transactionHash)
        self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)
      except Exception as e:
        error "Error processing community token deployment pending transaction event", msg=e.msg, receivedData

    self.events.on(PendingTransactionTypeDto.DeployOwnerToken.event) do(e: Args):
      var receivedData = TransactionMinedArgs(e)
      try:
        let deployState = if receivedData.success: DeployState.Deployed else: DeployState.Failed
        let ownerTransactionDetails = toOwnerTokenDeploymentTransactionDetails(parseJson(receivedData.data))
        if not receivedData.success:
          warn "Owner contracts not deployed", chainId=ownerTransactionDetails.ownerToken.chainId, address=ownerTransactionDetails.ownerToken.address
        var masterContractAddress = ownerTransactionDetails.masterToken.address
        var ownerContractAddress = ownerTransactionDetails.ownerToken.address

        try:
          # get master token address from transaction logs
          if receivedData.success:
            var response = tokens_backend.getOwnerTokenContractAddressFromHash(ownerTransactionDetails.ownerToken.chainId, receivedData.transactionHash)
            ownerContractAddress = response.result.getStr()
            if ownerContractAddress == "":
              raise newException(RpcException, "owner contract address is empty")
            response = tokens_backend.getMasterTokenContractAddressFromHash(ownerTransactionDetails.masterToken.chainId, receivedData.transactionHash)
            masterContractAddress = response.result.getStr()
            if masterContractAddress == "":
              raise newException(RpcException, "master contract address is empty")

          debug "Minted owner token contract address:", ownerContractAddress
          debug "Minted master token contract address:", masterContractAddress

          # update master token address
          discard updateCommunityTokenAddress(ownerTransactionDetails.masterToken.chainId, ownerTransactionDetails.masterToken.address, masterContractAddress)
          # update owner token address
          discard updateCommunityTokenAddress(ownerTransactionDetails.ownerToken.chainId, ownerTransactionDetails.ownerToken.address, ownerContractAddress)
          #update db state for owner and master token
          discard updateCommunityTokenState(ownerTransactionDetails.ownerToken.chainId, ownerContractAddress, deployState)
          discard updateCommunityTokenState(ownerTransactionDetails.masterToken.chainId, masterContractAddress, deployState)
          # now add owner token to community and publish update
          var response = tokens_backend.addCommunityToken(ownerTransactionDetails.communityId, ownerTransactionDetails.ownerToken.chainId, ownerContractAddress)
          if response.error != nil:
            let error = Json.decode($response.error, RpcError)
            raise newException(RpcException, "error adding owner token: " & error.message)

          # now add master token to community and publish update
          response = tokens_backend.addCommunityToken(ownerTransactionDetails.communityId, ownerTransactionDetails.masterToken.chainId, masterContractAddress)
          if response.error != nil:
            let error = Json.decode($response.error, RpcError)
            raise newException(RpcException, "error adding master token: " & error.message)
        except RpcException:
          error "Error updating owner contracts state", message = getCurrentExceptionMsg()

        let data = OwnerTokenDeployedStatusArgs(communityId: ownerTransactionDetails.communityId, chainId: ownerTransactionDetails.ownerToken.chainId,
                                                ownerContractAddress: ownerContractAddress,
                                                masterContractAddress: masterContractAddress,
                                                deployState: deployState,
                                                transactionHash: receivedData.transactionHash)
        self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOY_STATUS, data)
      except Exception as e:
        error "Error processing Owner token deployment pending transaction event", msg=e.msg, receivedData

    self.events.on(PendingTransactionTypeDto.AirdropCommunityToken.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      try:
        let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
        let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
        let data = AirdropArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus)
        self.events.emit(SIGNAL_AIRDROP_STATUS, data)

        # update owners list if burn was successfull
        if receivedData.success:
          self.tempTokenOwnersToFetch = tokenDto
          self.tokenOwners1SecTimer.start()
      except Exception as e:
        error "Error processing Collectible airdrop pending transaction event", msg=e.msg, receivedData

    self.events.on(PendingTransactionTypeDto.RemoteDestructCollectible.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      try:
        let remoteDestructTransactionDetails = toRemoteDestroyTransactionDetails(parseJson(receivedData.data))
        let tokenDto = self.getCommunityToken(remoteDestructTransactionDetails.chainId, remoteDestructTransactionDetails.contractAddress)
        let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
        let data = RemoteDestructArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus, remoteDestructAddresses: @[])
        self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)

        # update owners list if burn was successfull
        if receivedData.success:
          self.tempTokenOwnersToFetch = tokenDto
          self.tokenOwners1SecTimer.start()
      except Exception as e:
        error "Error processing Collectible self destruct pending transaction event", msg=e.msg, receivedData

    self.events.on(PendingTransactionTypeDto.BurnCommunityToken.event) do(e: Args):
      let receivedData = TransactionMinedArgs(e)
      try:
        let tokenDto = toCommunityTokenDto(parseJson(receivedData.data))
        let transactionStatus = if receivedData.success: ContractTransactionStatus.Completed else: ContractTransactionStatus.Failed
        if receivedData.success:
          try:
            discard updateCommunityTokenSupply(tokenDto.chainId, tokenDto.address, tokenDto.supply) #update db state
          except RpcException:
            error "Error updating collectibles supply", message = getCurrentExceptionMsg()
        let data = RemoteDestructArgs(communityToken: tokenDto, transactionHash: receivedData.transactionHash, status: transactionStatus)
        self.events.emit(SIGNAL_BURN_STATUS, data)
      except Exception as e:
        error "Error processing Collectible burn pending transaction event", msg=e.msg, receivedData

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

  proc createCommunityToken(self: Service, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto,
    chainId: int, contractAddress: string, communityId: string, addressFrom: string, privilegesLevel: PrivilegesLevel): CommunityTokenDto =
      result.tokenType = tokenMetadata.tokenType
      result.communityId = communityId
      result.address = contractAddress
      result.name = deploymentParams.name
      result.symbol = deploymentParams.symbol
      result.description = tokenMetadata.description
      result.supply = stint.parse($deploymentParams.supply, Uint256)
      result.infiniteSupply = deploymentParams.infiniteSupply
      result.transferable = deploymentParams.transferable
      result.remoteSelfDestruct = deploymentParams.remoteSelfDestruct
      result.tokenUri = deploymentParams.tokenUri
      result.chainId = chainId
      result.deployState = DeployState.InProgress
      result.decimals = deploymentParams.decimals
      result.deployer = addressFrom
      result.privilegesLevel = privilegesLevel

  proc saveTokenToDbAndWatchTransaction*(self:Service, communityToken: CommunityTokenDto, croppedImageJson: string,
    transactionHash: string, addressFrom: string, watchTransaction: bool) =
    var croppedImage = croppedImageJson.parseJson
    croppedImage{"imagePath"} = newJString(singletonInstance.utils.formatImagePath(croppedImage["imagePath"].getStr))

    # save token to db
    let communityTokenJson = tokens_backend.saveCommunityToken(communityToken, $croppedImage)
    let addedCommunityToken = communityTokenJson.result.toCommunityTokenDto()
    let data = CommunityTokenDeploymentArgs(communityToken: addedCommunityToken, transactionHash: transactionHash)
    self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOYMENT_STARTED, data)

    if watchTransaction:
      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        addedCommunityToken.address,
        $PendingTransactionTypeDto.DeployCommunityToken,
        $addedCommunityToken.toJsonNode(),
        addedCommunityToken.chainId,
      )

  proc temporaryMasterContractAddress*(ownerContractTransactionHash: string): string =
    return ownerContractTransactionHash & "-master"

  proc temporaryOwnerContractAddress*(ownerContractTransactionHash: string): string =
    return ownerContractTransactionHash & "-owner"

  proc deployOwnerContracts*(self: Service, communityId: string, addressFrom: string, password: string,
      ownerDeploymentParams: DeploymentParameters, ownerTokenMetadata: CommunityTokensMetadataDto,
      masterDeploymentParams: DeploymentParameters, masterTokenMetadata: CommunityTokensMetadataDto,
      croppedImageJson: string, chainId: int) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, "")
      if txData.source == parseAddress(ZERO_ADDRESS):
        return

      # set my pub key as signer
      let signerPubKey = singletonInstance.userProfile.getPubKey()

      # get deployment signature
      let signatureResponse = tokens_backend.createCommunityTokenDeploymentSignature(chainId, addressFrom, communityId)
      let signature = signatureResponse.result.getStr()

      # deploy contract
      let response = tokens_backend.deployOwnerToken(chainId, %ownerDeploymentParams, %masterDeploymentParams,
          signature, communityId, signerPubKey, %txData, common_utils.hashPassword(password))
      let transactionHash = response.result["transactionHash"].getStr()
      debug "Deployment transaction hash ", transactionHash=transactionHash

      var ownerToken = self.createCommunityToken(ownerDeploymentParams, ownerTokenMetadata, chainId, temporaryOwnerContractAddress(transactionHash), communityId, addressFrom, PrivilegesLevel.Owner)
      var masterToken = self.createCommunityToken(masterDeploymentParams, masterTokenMetadata, chainId, temporaryMasterContractAddress(transactionHash), communityId, addressFrom, PrivilegesLevel.Master)

      var croppedImage = croppedImageJson.parseJson
      ownerToken.image = croppedImage{"imagePath"}.getStr
      masterToken.image = croppedImage{"imagePath"}.getStr

      let ownerTokenJson = tokens_backend.saveCommunityToken(ownerToken, "")
      let addedOwnerToken = ownerTokenJson.result.toCommunityTokenDto()

      let masterTokenJson = tokens_backend.saveCommunityToken(masterToken, "")
      let addedMasterToken = masterTokenJson.result.toCommunityTokenDto()

      let data = OwnerTokenDeploymentArgs(ownerToken: addedOwnerToken, masterToken: addedMasterToken, transactionHash: transactionHash)
      self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOYMENT_STARTED, data)

      let transactionDetails = OwnerTokenDeploymentTransactionDetails(ownerToken: (chainId, addedOwnerToken.address),
        masterToken: (chainId, addedMasterToken.address), communityId: addedOwnerToken.communityId)

      self.transactionService.watchTransaction(
          transactionHash,
          addressFrom,
          addedOwnerToken.address,
          $PendingTransactionTypeDto.DeployOwnerToken,
          $(%transactionDetails),
          chainId,
        )
    except RpcException:
      error "Error deploying owner contract", message = getCurrentExceptionMsg()
      let data = OwnerTokenDeployedStatusArgs(communityId: communityId,
                                              deployState: DeployState.Failed)
      self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOY_STATUS, data)

  proc deployContract*(self: Service, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, croppedImageJson: string, chainId: int) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, "")
      if txData.source == parseAddress(ZERO_ADDRESS):
        return

      var response: RpcResponse[JsonNode]
      case tokenMetadata.tokenType
      of TokenType.ERC721:
        response = tokens_backend.deployCollectibles(chainId, %deploymentParams, %txData, common_utils.hashPassword(password))
      of TokenType.ERC20:
        response = tokens_backend.deployAssets(chainId, %deploymentParams, %txData, common_utils.hashPassword(password))
      else:
        error "Contract deployment error - unknown token type", tokenType=tokenMetadata.tokenType
        return

      let contractAddress = response.result["contractAddress"].getStr()
      let transactionHash = response.result["transactionHash"].getStr()
      debug "Deployed contract address ", contractAddress=contractAddress
      debug "Deployment transaction hash ", transactionHash=transactionHash

      var communityToken = self.createCommunityToken(deploymentParams, tokenMetadata, chainId, contractAddress, communityId, addressFrom, PrivilegesLevel.Community)

      self.saveTokenToDbAndWatchTransaction(communityToken, croppedImageJson, transactionHash, addressFrom, true)

    except RpcException:
      error "Error deploying contract", message = getCurrentExceptionMsg()
      let data = CommunityTokenDeployedStatusArgs(communityId: communityId,
                                                  deployState: DeployState.Failed)
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)

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

  proc getCommunityTokensDetailsAsync*(self: Service, communityId: string) =
    let arg = GetCommunityTokensDetailsArg(
      tptr: cast[ByteAddress](getCommunityTokensDetailsTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onCommunityTokensDetailsLoaded",
      communityId: communityId
    )
    self.threadpool.start(arg)

  proc onCommunityTokensDetailsLoaded*(self:Service, response: string) {.slot.} =
    try:
      let responseJson = response.parseJson()

      if responseJson["error"].getStr != "":
        raise newException(ValueError, responseJson["error"].getStr)

      let communityTokens = parseCommunityTokens(responseJson["communityTokensResponse"]["result"])
      let communityTokenJsonItems = responseJson["communityTokenJsonItems"]

      self.events.emit(SIGNAL_COMMUNITY_TOKENS_DETAILS_LOADED,
        CommunityTokensDetailsArgs(
          communityId: responseJson["communityId"].getStr,
          communityTokens: communityTokens,
          communityTokenJsonItems: communityTokenJsonItems,
        ))
    except Exception as e:
      error "Error getting community tokens details", message = e.msg

  proc getAllCommunityTokensAsync*(self: Service) =
    let arg = GetAllCommunityTokensArg(
      tptr: cast[ByteAddress](getAllCommunityTokensTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGotAllCommunityTokens",
    )
    self.threadpool.start(arg)

  proc onGotAllCommunityTokens*(self:Service, response: string) {.slot.} =
    try:
      let responseJson = parseJson(response)
      let communityTokens = map(responseJson["response"]["result"].getElems(),
        proc(x: JsonNode): CommunityTokenDto = x.toCommunityTokenDto())
      self.events.emit(SIGNAL_ALL_COMMUNITY_TOKENS_LOADED, CommunityTokensArgs(communityTokens: communityTokens))
    except RpcException as e:
      error "Error getting all community tokens async", message = e.msg

  proc removeCommunityToken*(self: Service, communityId: string, chainId: int, address: string) =
    try:
      let response = tokens_backend.removeCommunityToken(chainId, address)
      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "error removing community token: " & error.message)
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_REMOVED, CommunityTokenRemovedArgs(communityId: communityId, contractAddress: address, chainId: chainId))

    except RpcException as e:
      error "Error removing community token", message = getCurrentExceptionMsg()
      self.events.emit(SIGNAL_REMOVE_COMMUNITY_TOKEN_FAILED, Args())

  proc getCommunityTokenBySymbol*(self: Service, communityId: string, symbol: string): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.symbol == symbol:
        return token

  proc getCommunityToken*(self: Service, chainId: int, address: string): CommunityTokenDto =
    let communityTokens = self.getAllCommunityTokens()
    for token in communityTokens:
      if token.chainId == chainId and token.address == address:
        return token

  proc getCommunityTokenBurnState*(self: Service, chainId: int, contractAddress: string): ContractTransactionStatus =
    let burnTransactions = self.transactionService.getPendingTransactionsForType(PendingTransactionTypeDto.BurnCommunityToken)
    for transaction in burnTransactions:
      try:
        let communityToken = toCommunityTokenDto(parseJson(transaction.additionalData))
        if communityToken.chainId == chainId and communityToken.address == contractAddress:
          return ContractTransactionStatus.InProgress
      except Exception:
        discard
    return ContractTransactionStatus.Completed

  proc getRemoteDestructedAddresses*(self: Service, chainId: int, contractAddress: string): seq[string] =
    try:
      let remoteDestructTransactions = self.transactionService.getPendingTransactionsForType(PendingTransactionTypeDto.RemoteDestructCollectible)
      for transaction in remoteDestructTransactions:
        let remoteDestructTransactionDetails = toRemoteDestroyTransactionDetails(parseJson(transaction.additionalData))
        if remoteDestructTransactionDetails.chainId == chainId and remoteDestructTransactionDetails.contractAddress == contractAddress:
          return remoteDestructTransactionDetails.addresses
    except Exception:
      error "Error getting contract owner", message = getCurrentExceptionMsg()

  proc contractOwnerName*(self: Service, contractOwnerAddress: string): string =
    try:
      let res = self.walletAccountService.getAccountByAddress(contractOwnerAddress)
      if res == nil:
        error "getAccountByAddress result is nil"
        return ""
      return res.name
    except RpcException:
      error "Error getting contract owner name", message = getCurrentExceptionMsg()

  proc getRemainingSupply*(self: Service, chainId: int, contractAddress: string): Uint256 =
    try:
      let response = tokens_backend.remainingSupply(chainId, contractAddress)
      return stint.parse(response.result.getStr(), Uint256)
    except RpcException:
      error "Error getting remaining supply", message = getCurrentExceptionMsg()
    # if there is an exception probably community token is not minted yet
    return self.getCommunityToken(chainId, contractAddress).supply

  proc getRemoteDestructedAmount*(self: Service, chainId: int, contractAddress: string): Uint256 =
    try:
      let tokenType = self.getCommunityToken(chainId, contractAddress).tokenType
      if tokenType != TokenType.ERC721:
        return stint.parse("0", Uint256)
      let response = tokens_backend.remoteDestructedAmount(chainId, contractAddress)
      return stint.parse(response.result.getStr(), Uint256)
    except RpcException:
      error "Error getting remote destructed amount", message = getCurrentExceptionMsg()

  proc airdropTokens*(self: Service, communityId: string, password: string, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string], addressFrom: string) =
    try:
      for collectibleAndAmount in collectiblesAndAmounts:
        let txData = self.buildTransactionDataDto(addressFrom, collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
        if txData.source == parseAddress(ZERO_ADDRESS):
          return
        debug "Airdrop tokens ", chainId=collectibleAndAmount.communityToken.chainId, address=collectibleAndAmount.communityToken.address, amount=collectibleAndAmount.amount
        let response = tokens_backend.mintTokens(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address, %txData, common_utils.hashPassword(password), walletAddresses, collectibleAndAmount.amount)
        let transactionHash = response.result.getStr()
        debug "Airdrop transaction hash ", transactionHash=transactionHash

        var data = AirdropArgs(communityToken: collectibleAndAmount.communityToken, transactionHash: transactionHash, status: ContractTransactionStatus.InProgress)
        self.events.emit(SIGNAL_AIRDROP_STATUS, data)

        # observe transaction state
        self.transactionService.watchTransaction(
          transactionHash,
          addressFrom,
          collectibleAndAmount.communityToken.address,
          $PendingTransactionTypeDto.AirdropCommunityToken,
          $collectibleAndAmount.communityToken.toJsonNode(),
          collectibleAndAmount.communityToken.chainId,
        )
    except RpcException:
      error "Error airdropping tokens", message = getCurrentExceptionMsg()

  proc computeAirdropFee*(self: Service, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string], addressFrom: string, requestId: string) =
    try:
      self.tempTokensAndAmounts = collectiblesAndAmounts
      let arg = AsyncGetMintFees(
        tptr: cast[ByteAddress](asyncGetMintFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAirdropFees",
        collectiblesAndAmounts: collectiblesAndAmounts,
        walletAddresses: walletAddresses,
        addressFrom: addressFrom,
        requestId: requestId
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading airdrop fees", msg = e.msg
      var dataToEmit = AirdropFeesArgs()
      dataToEmit.errorCode =  ComputeFeeErrorCode.Other
      self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)

  proc getFiatValue*(self: Service, cryptoBalance: float, cryptoSymbol: string): float =
    if (cryptoSymbol == ""):
      return 0.0
    let currentCurrency = self.settingsService.getCurrency()
    let price = self.tokenService.getTokenPrice(cryptoSymbol, currentCurrency)
    return cryptoBalance * price

  proc findContractByUniqueId*(self: Service, contractUniqueKey: string): CommunityTokenDto =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if common_utils.contractUniqueKey(token.chainId, token.address) == contractUniqueKey:
        return token

  proc computeDeployFee*(self: Service, chainId: int, accountAddress: string, tokenType: TokenType, requestId: string) =
    try:
      if tokenType != TokenType.ERC20 and tokenType != TokenType.ERC721:
        error "Error loading fees: unknown token type", tokenType = tokenType
        return
      let arg = AsyncGetDeployFeesArg(
        tptr: cast[ByteAddress](asyncGetDeployFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onDeployFees",
        chainId: chainId,
        addressFrom: accountAddress,
        tokenType: tokenType,
        requestId: requestId
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg

  proc computeSetSignerFee*(self: Service, chainId: int, contractAddress: string, accountAddress: string, requestId: string) =
    try:
      let arg = AsyncSetSignerFeesArg(
        tptr: cast[ByteAddress](asyncSetSignerFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onSetSignerFees",
        chainId: chainId,
        contractAddress: contractAddress,
        addressFrom: accountAddress,
        requestId: requestId,
        newSignerPubKey: singletonInstance.userProfile.getPubKey()
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg


  proc computeDeployOwnerContractsFee*(self: Service, chainId: int, accountAddress: string, communityId: string, ownerDeploymentParams: DeploymentParameters, masterDeploymentParams: DeploymentParameters, requestId: string) =
    try:
      let arg = AsyncDeployOwnerContractsFeesArg(
        tptr: cast[ByteAddress](asyncGetDeployOwnerContractsFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onDeployOwnerContractsFees",
        chainId: chainId,
        addressFrom: accountAddress,
        requestId: requestId,
        signerPubKey: singletonInstance.userProfile.getPubKey(),
        communityId: communityId,
        ownerParams: %ownerDeploymentParams,
        masterParams: %masterDeploymentParams
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg

  proc getOwnerBalances(self: Service, contractOwners: seq[CommunityCollectibleOwner], ownerAddress: string): seq[CollectibleBalance] =
    for owner in contractOwners:
      if owner.collectibleOwner.address == ownerAddress:
        return owner.collectibleOwner.balances

  proc collectTokensToBurn(self: Service, walletAndAmountList: seq[WalletAndAmount], contractOwners: seq[CommunityCollectibleOwner]): seq[UInt256] =
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

  proc selfDestructCollectibles*(self: Service, communityId: string, password: string, walletAndAmounts: seq[WalletAndAmount], contractUniqueKey: string, addressFrom: string) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let tokenIds = self.getTokensToBurn(walletAndAmounts, contract)
      if len(tokenIds) == 0:
        return
      let txData = self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Remote destruct collectibles ", chainId=contract.chainId, address=contract.address, tokens=tokenIds
      let response = tokens_backend.remoteBurn(contract.chainId, contract.address, %txData, common_utils.hashPassword(password), tokenIds)
      let transactionHash = response.result.getStr()
      debug "Remote destruct transaction hash ", transactionHash=transactionHash

      var transactionDetails = RemoteDestroyTransactionDetails(chainId: contract.chainId, contractAddress: contract.address)
      for walletAndAmount in walletAndAmounts:
        transactionDetails.addresses.add(walletAndAmount.walletAddress)

      var data = RemoteDestructArgs(communityToken: contract, transactionHash: transactionHash, status: ContractTransactionStatus.InProgress, remoteDestructAddresses: transactionDetails.addresses)
      self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)

      # observe transaction state
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contract.address,
        $PendingTransactionTypeDto.RemoteDestructCollectible,
        $(%transactionDetails),
        contract.chainId,
      )
    except Exception as e:
      error "Remote self destruct error", msg = e.msg

  proc computeSelfDestructFee*(self: Service, walletAndAmountList: seq[WalletAndAmount], contractUniqueKey: string, addressFrom: string, requestId: string) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
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
        tokenIds: tokenIds,
        addressFrom: addressFrom,
        requestId: requestId
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

  proc burnTokens*(self: Service, communityId: string, password: string, contractUniqueKey: string, amount: Uint256, addressFrom: string) =
    try:
      var contract = self.findContractByUniqueId(contractUniqueKey)
      let txData = self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Burn tokens ", chainId=contract.chainId, address=contract.address, amount=amount
      let response = tokens_backend.burn(contract.chainId, contract.address, %txData, common_utils.hashPassword(password), amount)
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
        $PendingTransactionTypeDto.BurnCommunityToken,
        $contract.toJsonNode(),
        contract.chainId,
      )
    except Exception as e:
      error "Burn error", msg = e.msg

  proc setSigner*(self: Service, password: string, communityId: string, chainId: int, contractAddress: string, addressFrom: string) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, contractAddress)
      debug "Set signer ", chainId=chainId, address=contractAddress
      let signerPubKey = singletonInstance.userProfile.getPubKey()
      let response = tokens_backend.setSignerPubKey(chainId, contractAddress, %txData, signerPubKey, common_utils.hashPassword(password))
      let transactionHash = response.result.getStr()
      debug "Set signer transaction hash ", transactionHash=transactionHash

      let data = SetSignerArgs(status: ContractTransactionStatus.InProgress,
                              chainId: chainId,
                              transactionHash: transactionHash,
                              communityId: communityId)

      self.events.emit(SIGNAL_SET_SIGNER_STATUS, data)

      # observe transaction state
      let contractDetails = ContractDetails(chainId: chainId, contractAddress: contractAddress, communityId: communityId)
      self.transactionService.watchTransaction(
        transactionHash,
        addressFrom,
        contractAddress,
        $PendingTransactionTypeDto.SetSignerPublicKey,
        $(%contractDetails),
        chainId,
      )
    except Exception as e:
      error "Set signer error", msg = e.msg

  proc computeBurnFee*(self: Service, contractUniqueKey: string, amount: Uint256, addressFrom: string, requestId: string) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let arg = AsyncGetBurnFees(
        tptr: cast[ByteAddress](asyncGetBurnFeesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onBurnFees",
        chainId: contract.chainId,
        contractAddress: contract.address,
        amount: amount,
        addressFrom: addressFrom,
        requestId: requestId
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading burn fees", msg = e.msg

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
    let tokens = self.walletAccountService.getTokensByAddress(walletAddress.toLower())
    for token in tokens:
      if token.symbol == ethSymbol:
        return token.balancesPerChain[chainId].balance

  proc createComputeFeeArgsFromEthAndBalance(self: Service, ethValue: float, balance: float): ComputeFeeArgs =
    let fiatValue = self.getFiatValue(ethValue, ethSymbol)
    let (ethCurrency, fiatCurrency) = self.createCurrencyAmounts(ethValue, fiatValue)
    return ComputeFeeArgs(ethCurrency: ethCurrency, fiatCurrency: fiatCurrency,
                                    errorCode: (if ethValue > balance: ComputeFeeErrorCode.Balance else: ComputeFeeErrorCode.Success))

  proc createComputeFeeArgs(self: Service, gasUnits: int, suggestedFees: SuggestedFeesDto, chainId: int, walletAddress: string): ComputeFeeArgs =
    let ethValue = self.computeEthValue(gasUnits, suggestedFees)
    let balance = self.getWalletBalanceForChain(walletAddress, chainId)
    debug "computing fees", walletBalance=balance, ethValue=ethValue
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
    let responseJson = response.parseJson()
    try:
      let errorMessage = responseJson{"error"}.getStr
      if errorMessage != "":
        let data = self.createComputeFeeArgsWithError(errorMessage)
        data.requestId = responseJson{"requestId"}.getStr
        self.events.emit(signalName, data)
        return
      let gasTable = responseJson{"gasTable"}.toGasTable
      let feeTable = responseJson{"feeTable"}.toFeeTable
      let chainId = responseJson{"chainId"}.getInt
      let addressFrom = responseJson{"addressFrom"}.getStr
      self.tempGasTable = gasTable
      self.tempFeeTable = feeTable
      let gasUnits = toSeq(gasTable.values())[0]
      let suggestedFees = toSeq(feeTable.values())[0]
      let data = self.createComputeFeeArgs(gasUnits, suggestedFees, chainId, addressFrom)
      data.requestId = responseJson{"requestId"}.getStr
      self.events.emit(signalName, data)
    except Exception:
      error "Error creating fee args", message = getCurrentExceptionMsg()
      let data = self.createComputeFeeArgsWithError(getCurrentExceptionMsg())
      data.requestId = responseJson{"requestId"}.getStr
      self.events.emit(signalName, data)

  proc onDeployOwnerContractsFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_DEPLOY_FEE)

  proc onSelfDestructFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_SELF_DESTRUCT_FEE)

  proc onBurnFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_BURN_FEE)

  proc onDeployFees*(self:Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_DEPLOY_FEE)

  proc onSetSignerFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_SET_SIGNER_FEE)

  proc onAirdropFees*(self:Service, response: string) {.slot.} =
    var wholeEthCostForChainWallet: Table[ChainWalletTuple, float]
    var ethValuesForContracts: Table[ContractTuple, float]
    var allComputeFeeArgs: seq[ComputeFeeArgs]
    var dataToEmit = AirdropFeesArgs()
    dataToEmit.errorCode =  ComputeFeeErrorCode.Success
    let responseJson = response.parseJson()

    try:
      let errorMessage = responseJson{"error"}.getStr
      let requestId = responseJson{"requestId"}.getStr
      if errorMessage != "":
        for collectibleAndAmount in self.tempTokensAndAmounts:
          let args = self.createComputeFeeArgsWithError(errorMessage)
          args.contractUniqueKey = common_utils.contractUniqueKey(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)
          dataToEmit.fees.add(args)
        let (ethTotal, fiatTotal) = self.create0CurrencyAmounts()
        dataToEmit.totalEthFee = ethTotal
        dataToEmit.totalFiatFee = fiatTotal
        dataToEmit.errorCode = self.getErrorCodeFromMessage(errorMessage)
        dataToEmit.requestId = requestId
        self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)
        return

      let gasTable = responseJson{"gasTable"}.toGasTable
      let feeTable = responseJson{"feeTable"}.toFeeTable
      let addressFrom = responseJson{"addressFrom"}.getStr
      self.tempGasTable = gasTable
      self.tempFeeTable = feeTable

      # compute eth cost for every contract
      # also sum all eth costs per (chain, wallet) - it will be needed to compare with (chain, wallet) balance
      for collectibleAndAmount in self.tempTokensAndAmounts:
        let gasUnits = self.tempGasTable[(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)]
        let suggestedFees = self.tempFeeTable[collectibleAndAmount.communityToken.chainId]
        let ethValue = self.computeEthValue(gasUnits, suggestedFees)
        wholeEthCostForChainWallet[(collectibleAndAmount.communityToken.chainId, addressFrom)] = wholeEthCostForChainWallet.getOrDefault((collectibleAndAmount.communityToken.chainId, addressFrom), 0.0) + ethValue
        ethValuesForContracts[(collectibleAndAmount.communityToken.chainId, collectibleAndAmount.communityToken.address)] = ethValue

      var totalEthVal = 0.0
      var totalFiatVal = 0.0
      # for every contract create cost Args
      for collectibleAndAmount in self.tempTokensAndAmounts:
        let contractTuple = (chainId: collectibleAndAmount.communityToken.chainId,
                                          address: collectibleAndAmount.communityToken.address)
        let ethValue = ethValuesForContracts[contractTuple]
        var balance = self.getWalletBalanceForChain(addressFrom, contractTuple.chainId)
        if balance < wholeEthCostForChainWallet[(contractTuple.chainId, addressFrom)]:
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
      dataToEmit.requestId = requestId
      self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)

    except Exception as e:
      error "Error computing airdrop fees", msg = e.msg
      dataToEmit.errorCode = ComputeFeeErrorCode.Other
      dataToEmit.requestId = responseJson{"requestId"}.getStr
      self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)

  proc fetchCommunityOwners*(self: Service,  communityToken: CommunityTokenDto) =
    if communityToken.tokenType != TokenType.ERC721:
      # TODO we need a new implementation for ERC20
      # we will be able to show only tokens hold by community members
      return
    let arg = FetchCollectibleOwnersArg(
      tptr: cast[ByteAddress](fetchCollectibleOwnersTaskArg),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onCommunityTokenOwnersFetched",
      chainId: communityToken.chainId,
      contractAddress: communityToken.address,
      communityId: communityToken.communityId
    )
    self.threadpool.start(arg)

  # get owners from cache
  proc getCommunityTokenOwners*(self: Service, communityId: string, chainId: int, contractAddress: string): seq[CommunityCollectibleOwner] =
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
    var owners = fromJson(resultJson, CollectibleContractOwnership).owners
    owners = owners.filter(x => x.address != ZERO_ADDRESS)

    let response = communities_backend.getCommunityMembersForWalletAddresses(communityId, chainId)
    if response.error != nil:
      let errorMessage = responseJson["error"].getStr
      error "Can't get community members with addresses", errorMsg=errorMessage
      return

    let communityOwners = owners.map(proc(owner: CollectibleOwner): CommunityCollectibleOwner =
      let ownerAddressUp = owner.address.toUpper()
      for responseAddress in response.result.keys():
        let responseAddressUp = responseAddress.toUpper()
        if ownerAddressUp == responseAddressUp:
          let member = response.result[responseAddress].toContactsDto()
          return CommunityCollectibleOwner(
            contactId: member.id,
            name: member.displayName,
            imageSource: member.image.thumbnail,
            collectibleOwner: owner
          )
      return CommunityCollectibleOwner(collectibleOwner: owner)
    )
    self.tokenOwnersCache[(chainId, contractAddress)] = communityOwners
    let data = CommunityTokenOwnersArgs(chainId: chainId, contractAddress: contractAddress, communityId: communityId, owners: communityOwners)
    self.events.emit(SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED, data)

  proc onRefreshTransferableTokenOwners*(self:Service) {.slot.} =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if token.transferable:
        self.fetchCommunityOwners(token)

  proc onFetchTempTokenOwners*(self: Service) {.slot.} =
    self.fetchCommunityOwners(self.tempTokenOwnersToFetch)

  proc fetchAllTokenOwners*(self: Service) =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      self.fetchCommunityOwners(token)

  proc fetchCommunityTokenOwners*(self: Service, communityId: string) =
    let tokens = self.getCommunityTokens(communityId)
    for token in tokens:
      self.fetchCommunityOwners(token)

  proc getOwnerToken*(self: Service, communityId: string): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.privilegesLevel == PrivilegesLevel.Owner:
        return token

  proc getTokenMasterToken*(self: Service, communityId: string): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.privilegesLevel == PrivilegesLevel.Master:
        return token

  proc declineOwnership*(self: Service, communityId: string) =
    let notification = self.acService.getNotificationForTypeAndCommunityId(notification.ActivityCenterNotificationType.OwnerTokenReceived, communityId)
    if notification != nil:
      discard self.acService.deleteActivityCenterNotifications(@[notification.id])
    try:
      let response = tokens_backend.registerSetSignerDeclinedNotification(communityId)
      checkAndEmitACNotificationsFromResponse(self.events, response.result{"activityCenterNotifications"})
    except Exception as e:
      error "Error registering decline set signer notification", msg=e.msg
    let finaliseStatusArgs = FinaliseOwnershipStatusArgs(isPending: false, communityId: communityId)
    self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)

  proc asyncGetOwnerTokenOwnerAddress*(self: Service, chainId: int, contractAddress: string) =
    let arg = GetOwnerTokenOwnerAddressArgs(
      tptr: cast[ByteAddress](getOwnerTokenOwnerAddressTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onGetOwnerTokenOwner",
      chainId: chainId,
      contractAddress: contractAddress
    )
    self.threadpool.start(arg)

  proc onGetOwnerTokenOwner*(self:Service, response: string) {.slot.} =
    var ownerTokenArgs = OwnerTokenOwnerAddressArgs()
    try:
      let responseJson = response.parseJson()
      ownerTokenArgs.chainId = responseJson{"chainId"}.getInt
      ownerTokenArgs.contractAddress = responseJson{"contractAddress"}.getStr
      let errorMsg = responseJson["error"].getStr
      if errorMsg != "":
        error "can't get owner token owner address", errorMsg
      else:
        ownerTokenArgs.address = responseJson{"address"}.getStr
        let acc = self.walletAccountService.getAccountByAddress(ownerTokenArgs.address)
        if acc == nil:
          error "getAccountByAddress result is nil"
        else:
          ownerTokenArgs.addressName = acc.name
    except Exception:
      error "can't get owner token owner address", message = getCurrentExceptionMsg()
    self.events.emit(SIGNAL_OWNER_TOKEN_OWNER_ADDRESS, ownerTokenArgs)