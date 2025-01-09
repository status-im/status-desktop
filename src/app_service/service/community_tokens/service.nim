import
  NimQml,
  Tables,
  chronicles,
  json,
  stint,
  strutils,
  sugar,
  sequtils,
  stew/shims/strformat,
  times
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
import app_service/service/currency/service as currency_service
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

type CommunityTokenDeployedStatusArgs* = ref object of Args
  communityId*: string
  contractAddress*: string
  chainId*: int
  transactionHash*: string
  deployState*: DeployState

type OwnerTokenDeployedStatusArgs* = ref object of Args
  communityId*: string
  chainId*: int
  ownerContractAddress*: string
  masterContractAddress*: string
  transactionHash*: string
  deployState*: DeployState

type CommunityTokensArgs* = ref object of Args
  communityTokens*: seq[CommunityTokenDto]

type CommunityTokenDeploymentArgs* = ref object of Args
  communityToken*: CommunityTokenDto
  transactionHash*: string

type OwnerTokenDeploymentArgs* = ref object of Args
  ownerToken*: CommunityTokenDto
  masterToken*: CommunityTokenDto
  transactionHash*: string

type CommunityTokenRemovedArgs* = ref object of Args
  communityId*: string
  contractAddress*: string
  chainId*: int

type OwnerTokenOwnerAddressArgs* = ref object of Args
  chainId*: int
  contractAddress*: string
  address*: string
  addressName*: string

type RemoteDestructArgs* = ref object of Args
  communityToken*: CommunityTokenDto
  transactionHash*: string
  status*: ContractTransactionStatus
  remoteDestructAddresses*: seq[string]

type AirdropArgs* = ref object of Args
  communityToken*: CommunityTokenDto
  transactionHash*: string
  status*: ContractTransactionStatus

type ComputeFeeArgs* = ref object of Args
  ethCurrency*: CurrencyAmount
  fiatCurrency*: CurrencyAmount
  errorCode*: ComputeFeeErrorCode
  contractUniqueKey*: string # used for minting
  requestId*: string

type SetSignerArgs* = ref object of Args
  transactionHash*: string
  status*: ContractTransactionStatus
  communityId*: string
  chainId*: int

proc `%`*(self: ComputeFeeArgs): JsonNode =
  result =
    %*{
      "ethFee":
        if self.ethCurrency == nil:
          newCurrencyAmount().toJsonNode()
        else:
          self.ethCurrency.toJsonNode(),
      "fiatFee":
        if self.fiatCurrency == nil:
          newCurrencyAmount().toJsonNode()
        else:
          self.fiatCurrency.toJsonNode(),
      "errorCode": self.errorCode.int,
      "contractUniqueKey": self.contractUniqueKey,
    }

proc computeFeeArgsToJsonArray(args: seq[ComputeFeeArgs]): JsonNode =
  let arr = newJArray()
  for arg in args:
    arr.elems.add(%arg)
  return arr

type AirdropFeesArgs* = ref object of Args
  fees*: seq[ComputeFeeArgs]
  totalEthFee*: CurrencyAmount
  totalFiatFee*: CurrencyAmount
  errorCode*: ComputeFeeErrorCode
  requestId*: string

proc `%`*(self: AirdropFeesArgs): JsonNode =
  result =
    %*{
      "fees": computeFeeArgsToJsonArray(self.fees),
      "totalEthFee":
        if self.totalEthFee == nil:
          newCurrencyAmount().toJsonNode()
        else:
          self.totalEthFee.toJsonNode(),
      "totalFiatFee":
        if self.totalFiatFee == nil:
          newCurrencyAmount().toJsonNode()
        else:
          self.totalFiatFee.toJsonNode(),
      "errorCode": self.errorCode.int,
      "requestId": self.requestId,
    }

type CommunityTokenOwnersArgs* = ref object of Args
  communityId*: string
  contractAddress*: string
  chainId*: int
  owners*: seq[CommunityCollectibleOwner]
  error*: string

type CommunityTokensDetailsArgs* = ref object of Args
  communityId*: string
  communityTokens*: seq[CommunityTokenDto]
  communityTokenJsonItems*: JsonNode

type OwnerTokenReceivedArgs* = ref object of Args
  communityId*: string
  communityName*: string
  chainId*: int
  contractAddress*: string

type CommunityTokenReceivedArgs* = ref object of Args
  name*: string
  image*: string
  address*: string
  collectibleId*: CollectibleUniqueID
  communityId*: string
  communityName*: string
  chainId*: int
  amount*: float64
  txHash*: string
  symbol*: string
  decimals*: int
  verified*: bool
  tokenListID*: string
  isFirst*: bool
  tokenType*: int
  accountAddress*: string
  accountName*: string
  isWatchOnlyAccount*: bool

proc `$`*(self: CommunityTokenReceivedArgs): string =
  return
    fmt"""CommunityTokenReceivedArgs(
    name: {self.name},
    image: {self.image},
    communityId: {self.communityId},
    communityName: {self.communityName},
    chainId: {self.chainId},
    amount: {self.amount},
    decimals: {self.decimals},
    verified: {self.verified},
    tokenListID: {self.tokenListID},
    txHash: {self.txHash},
    symbol: {self.symbol},
    isFirst: {self.isFirst},
    tokenType: {self.tokenType},
    accountAddress: {self.accountAddress},
    accountName: {self.accountName},
    isWatchOnlyAccount: {self.isWatchOnlyAccount}
  )"""

proc toTokenData*(self: CommunityTokenReceivedArgs): string =
  var dataNode =
    %*{
      "chainId": self.chainId,
      "txHash": self.txHash,
      "walletAddress": self.accountAddress,
      "isFirst": self.isFirst,
      "communityId": self.communityId,
      "amount": $self.amount,
      "name": self.name,
      "symbol": self.symbol,
      "tokenType": self.tokenType,
    }
  if not self.collectibleId.isNil:
    dataNode.add("collectibleId", %self.collectibleId)
  return $dataNode

type FinaliseOwnershipStatusArgs* = ref object of Args
  isPending*: bool
  communityId*: string

type ContractDetails* = object
  chainId*: int
  contractAddress*: string
  communityId*: string

proc `%`*(self: ContractDetails): JsonNode =
  result =
    %*{
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
const SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS* =
  "communityTokens-communityTokenDeployStatus"
const SIGNAL_COMMUNITY_TOKEN_DEPLOYMENT_STARTED* =
  "communityTokens-communityTokenDeploymentStarted"
const SIGNAL_COMPUTE_DEPLOY_FEE* = "communityTokens-computeDeployFee"
const SIGNAL_COMPUTE_SET_SIGNER_FEE* = "communityTokens-computeSetSignerFee"
const SIGNAL_COMPUTE_SELF_DESTRUCT_FEE* = "communityTokens-computeSelfDestructFee"
const SIGNAL_COMPUTE_BURN_FEE* = "communityTokens-computeBurnFee"
const SIGNAL_COMPUTE_AIRDROP_FEE* = "communityTokens-computeAirdropFee"
const SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED* =
  "communityTokens-communityTokenOwnersFetched"
const SIGNAL_COMMUNITY_TOKEN_OWNERS_LOADING_FAILED* =
  "communityTokens-communityTokenOwnersLoadingFailed"
const SIGNAL_REMOTE_DESTRUCT_STATUS* =
  "communityTokens-communityTokenRemoteDestructStatus"
const SIGNAL_BURN_STATUS* = "communityTokens-communityTokenBurnStatus"
const SIGNAL_BURN_ACTION_RECEIVED* = "communityTokens-communityTokenBurnActionReceived"
const SIGNAL_AIRDROP_STATUS* = "communityTokens-airdropStatus"
const SIGNAL_REMOVE_COMMUNITY_TOKEN_FAILED* =
  "communityTokens-removeCommunityTokenFailed"
const SIGNAL_COMMUNITY_TOKEN_REMOVED* = "communityTokens-communityTokenRemoved"
const SIGNAL_OWNER_TOKEN_DEPLOY_STATUS* = "communityTokens-ownerTokenDeployStatus"
const SIGNAL_OWNER_TOKEN_DEPLOYMENT_STARTED* =
  "communityTokens-ownerTokenDeploymentStarted"
const SIGNAL_COMMUNITY_TOKENS_DETAILS_LOADED* =
  "communityTokens-communityTokenDetailsLoaded"
const SIGNAL_OWNER_TOKEN_RECEIVED* = "communityTokens-ownerTokenReceived"
const SIGNAL_SET_SIGNER_STATUS* = "communityTokens-setSignerStatus"
const SIGNAL_FINALISE_OWNERSHIP_STATUS* = "communityTokens-finaliseOwnershipStatus"
const SIGNAL_OWNER_TOKEN_OWNER_ADDRESS* = "communityTokens-ownerTokenOwnerAddress"
const SIGNAL_COMMUNITY_TOKEN_RECEIVED* = "communityTokens-communityTokenReceived"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    transactionService: transaction_service.Service
    tokenService: token_service.Service
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    acService: ac_service.Service
    communityService: community_service.Service
    currencyService: currency_service.Service

    tokenOwnersCache: Table[ContractTuple, seq[CommunityCollectibleOwner]]

    tempFeeTable: Table[int, SuggestedFeesDto]
      # fees per chain, filled during gas computation, used during operation (deployment, mint, burn)
    tempGasTable: Table[ContractTuple, int]
      # gas per contract, filled during gas computation, used during operation (deployment, mint, burn)
    tempTokensAndAmounts: seq[CommunityTokenAndAmount]

    communityTokensCache: seq[CommunityTokenDto]

    # keep times when token holders list for contracts were updated
    tokenHoldersLastUpdateMap: Table[ContractTuple, int64]
    # timer which fetches token holders
    tokenHoldersTimer: QTimer
    # token for which token holders are fetched
    tokenHoldersToken: CommunityTokenDto
    # flag to indicate that token holders management started
    tokenHoldersManagementStarted: bool

  # Forward declaration
  proc getAllCommunityTokensAsync*(self: Service)
  proc getCommunityTokenOwners*(
    self: Service, communityId: string, chainId: int, contractAddress: string
  ): seq[CommunityCollectibleOwner]

  proc getCommunityToken*(
    self: Service, chainId: int, address: string
  ): CommunityTokenDto

  proc findContractByUniqueId*(
    self: Service, contractUniqueKey: string
  ): CommunityTokenDto

  proc restartTokenHoldersTimer(self: Service, chainId: int, contractAddress: string)
  proc refreshTokenHolders(self: Service, token: CommunityTokenDto)

  proc delete*(self: Service) =
    delete(self.tokenHoldersTimer)
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      transactionService: transaction_service.Service,
      tokenService: token_service.Service,
      settingsService: settings_service.Service,
      walletAccountService: wallet_account_service.Service,
      acService: ac_service.Service,
      communityService: community_service.Service,
      currencyService: currency_service.Service,
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
    result.currencyService = currencyService

    result.tokenHoldersTimer = newQTimer()
    result.tokenHoldersTimer.setSingleShot(true)
    signalConnect(
      result.tokenHoldersTimer, "timeout()", result, "onTokenHoldersTimeout()", 2
    )

  # cache functions
  proc updateCommunityTokenCache(
      self: Service, chainId: int, address: string, tokenToUpdate: CommunityTokenDto
  ) =
    for i in 0 .. self.communityTokensCache.len - 1:
      if self.communityTokensCache[i].chainId == chainId and
          self.communityTokensCache[i].address == address:
        self.communityTokensCache[i] = tokenToUpdate
        return

  proc removeCommunityTokenAndUpdateCache(
      self: Service, chainId: int, contractAddress: string
  ) =
    discard tokens_backend.removeCommunityToken(chainId, contractAddress)
    self.communityTokensCache = self.communityTokensCache.filter(
      x => ((x.chainId != chainId) or (x.address != contractAddress))
    )

  # end of cache functions

  proc processReceivedCollectiblesWalletEvent(
      self: Service, jsonMessage: string, accounts: seq[string]
  ) =
    try:
      let dataMessageJson = parseJson(jsonMessage)
      let tokenDataPayload =
        fromJson(dataMessageJson, CommunityCollectiblesReceivedPayload)

      let watchOnlyAccounts = self.walletAccountService.getWatchOnlyAccounts()
      if any(
        watchOnlyAccounts,
        proc(x: WalletAccountDto): bool =
          x.address == accounts[0],
      ):
        # skip events on watch-only accounts
        return

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
          debug "received owner token",
            contractAddress = contractAddress, chainId = chainId
          let tokenReceivedArgs = OwnerTokenReceivedArgs(
            communityId: communityId,
            communityName: communityName,
            chainId: chainId,
            contractAddress: contractAddress,
          )
          self.events.emit(SIGNAL_OWNER_TOKEN_RECEIVED, tokenReceivedArgs)
          let finaliseStatusArgs =
            FinaliseOwnershipStatusArgs(isPending: true, communityId: communityId)
          self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)

          let response =
            tokens_backend.registerOwnerTokenReceivedNotification(communityId)
          checkAndEmitACNotificationsFromResponse(
            self.events, response.result{"activityCenterNotifications"}
          )
        elif privilegesLevel == PrivilegesLevel.Community:
          var collectibleName, collectibleImage, txHash, accountName, accountAddress:
            string
          var isFirst = false
          var amount = float64(1.0)

          if len(accounts) > 0:
            accountAddress = accounts[0]
            let res = self.walletAccountService.getAccountByAddress(accountAddress)
            accountName = res.name

          if coll.isFirst.isSome():
            isFirst = coll.isFirst.get()
          if coll.latestTxHash.isSome():
            txHash = coll.latestTxHash.get()
          if coll.receivedAmount.isSome():
            amount = coll.receivedAmount.get()

          if coll.collectibleData.isSome():
            let collData = coll.collectibleData.get()
            collectibleName = collData.name
            if collData.imageUrl.isSome():
              collectibleImage = collData.imageUrl.get()

          let tokenReceivedArgs = CommunityTokenReceivedArgs(
            collectibleId: id,
            communityId: communityId,
            communityName: communityData.name,
            chainId: id.contractID.chainID,
            txHash: txHash,
            name: collectibleName,
            amount: amount,
            image: collectibleImage,
            isFirst: isFirst,
            tokenType: int(TokenType.ERC721),
            accountAddress: accountAddress,
            accountName: accountName,
          )
          self.events.emit(SIGNAL_COMMUNITY_TOKEN_RECEIVED, tokenReceivedArgs)

          let response = tokens_backend.registerReceivedCommunityTokenNotification(
            communityId, isFirst, tokenReceivedArgs.toTokenData()
          )
          checkAndEmitACNotificationsFromResponse(
            self.events, response.result{"activityCenterNotifications"}
          )
    except Exception as e:
      error "Error registering collectibles token received notification", msg = e.msg

  proc processReceivedCommunityTokenWalletEvent(
      self: Service, jsonMessage: string, accounts: seq[string]
  ) =
    try:
      let dataMessageJson = parseJson(jsonMessage)
      let tokenDataPayload = fromJson(dataMessageJson, CommunityTokenReceivedPayload)
      if len(tokenDataPayload.communityId) == 0:
        return

      let watchOnlyAccounts = self.walletAccountService.getWatchOnlyAccounts()
      var accountName, accountAddress: string
      if len(accounts) > 0:
        accountAddress = accounts[0]
        let res = self.walletAccountService.getAccountByAddress(accountAddress)
        accountName = res.name

      let communityId = tokenDataPayload.communityId
      let tokenReceivedArgs = CommunityTokenReceivedArgs(
        communityId: communityId,
        communityName: tokenDataPayload.communityName,
        chainId: tokenDataPayload.chainId,
        txHash: tokenDataPayload.txHash,
        address: "0x" & tokenDataPayload.address.toHex(),
        name: tokenDataPayload.name,
        amount: tokenDataPayload.amount,
        decimals: tokenDataPayload.decimals,
        verified: tokenDataPayload.verified,
        tokenListID: tokenDataPayload.tokenListID,
        image: tokenDataPayload.image,
        symbol: tokenDataPayload.symbol,
        isFirst: tokenDataPayload.isFirst,
        tokenType: int(TokenType.ERC20),
        accountAddress: accountAddress,
        accountName: accountName,
        isWatchOnlyAccount: any(
          watchOnlyAccounts,
          proc(x: WalletAccountDto): bool =
            x.address == accounts[0],
        ),
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_RECEIVED, tokenReceivedArgs)

      let response = tokens_backend.registerReceivedCommunityTokenNotification(
        communityId, tokenDataPayload.isFirst, tokenReceivedArgs.toTokenData()
      )
      checkAndEmitACNotificationsFromResponse(
        self.events, response.result{"activityCenterNotifications"}
      )
    except Exception as e:
      error "Error registering community token received notification", msg = e.msg

  proc processSetSignerTransactionEvent(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let chainId = signalArgs.communityToken.chainId
      let communityId = signalArgs.communityToken.communityId

      if signalArgs.success:
        let finaliseStatusArgs =
          FinaliseOwnershipStatusArgs(isPending: false, communityId: communityId)
        self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)
      else:
        error "Signer not set"

      let data = SetSignerArgs(
        status:
          if signalArgs.success:
            ContractTransactionStatus.Completed
          else:
            ContractTransactionStatus.Failed,
        chainId: chainId,
        transactionHash: signalArgs.hash,
        communityId: communityId,
      )
      self.events.emit(SIGNAL_SET_SIGNER_STATUS, data)

      # TODO move AC notifications to status-go
      let response =
        if signalArgs.success:
          tokens_backend.registerReceivedOwnershipNotification(communityId)
        else:
          tokens_backend.registerSetSignerFailedNotification(communityId)
      checkAndEmitACNotificationsFromResponse(
        self.events, response.result{"activityCenterNotifications"}
      )

      let notificationToSetRead = self.acService.getNotificationForTypeAndCommunityId(
        notification.ActivityCenterNotificationType.OwnerTokenReceived, communityId
      )
      if notificationToSetRead != nil:
        self.acService.markActivityCenterNotificationRead(notificationToSetRead.id)
    except Exception as e:
      error "Error processing set signer transaction", msg = e.msg

  proc processAirdropTransactionEvent(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let transactionStatus =
        if signalArgs.success:
          ContractTransactionStatus.Completed
        else:
          ContractTransactionStatus.Failed
      let data = AirdropArgs(
        communityToken: signalArgs.communityToken,
        transactionHash: signalArgs.hash,
        status: transactionStatus,
      )
      self.events.emit(SIGNAL_AIRDROP_STATUS, data)

      # update owners list if airdrop was successfull
      if signalArgs.success:
        self.refreshTokenHolders(signalArgs.communityToken)
    except Exception as e:
      error "Error processing airdrop pending transaction event", msg = e.msg

  proc processRemoteDestructEvent(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let transactionStatus =
        if signalArgs.success:
          ContractTransactionStatus.Completed
        else:
          ContractTransactionStatus.Failed
      let data = RemoteDestructArgs(
        communityToken: signalArgs.communityToken,
        transactionHash: signalArgs.hash,
        status: transactionStatus,
        remoteDestructAddresses: @[],
      )
      self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)

      # update owners list if remote destruct was successfull
      if signalArgs.success:
        self.refreshTokenHolders(signalArgs.communityToken)
    except Exception as e:
      error "Error processing collectible self destruct pending transaction event",
        msg = e.msg

  proc processBurnEvent(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let transactionStatus =
        if signalArgs.success:
          ContractTransactionStatus.Completed
        else:
          ContractTransactionStatus.Failed
      if signalArgs.success:
        self.updateCommunityTokenCache(
          signalArgs.communityToken.chainId, signalArgs.communityToken.address,
          signalArgs.communityToken,
        )
      let data = RemoteDestructArgs(
        communityToken: signalArgs.communityToken,
        transactionHash: signalArgs.hash,
        status: transactionStatus,
      )
      self.events.emit(SIGNAL_BURN_STATUS, data)
    except Exception as e:
      error "Error processing collectible burn pending transaction event", msg = e.msg

  proc processDeployCommunityToken(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let deployState =
        if signalArgs.success: DeployState.Deployed else: DeployState.Failed
      let tokenDto = signalArgs.communityToken
      if not signalArgs.success:
        error "Community contract not deployed",
          chainId = tokenDto.chainId, address = tokenDto.address
      self.updateCommunityTokenCache(tokenDto.chainId, tokenDto.address, tokenDto)
      let data = CommunityTokenDeployedStatusArgs(
        communityId: tokenDto.communityId,
        contractAddress: tokenDto.address,
        deployState: deployState,
        chainId: tokenDto.chainId,
        transactionHash: signalArgs.hash,
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)
    except Exception as e:
      error "Error processing community token deployment pending transaction event",
        msg = e.msg

  proc processDeployOwnerToken(
      self: Service, signalArgs: CommunityTokenTransactionStatusChangedSignal
  ) =
    try:
      let deployState =
        if signalArgs.success: DeployState.Deployed else: DeployState.Failed
      let ownerToken = signalArgs.ownerToken
      let masterToken = signalArgs.masterToken
      if not signalArgs.success:
        error "Owner token contract not deployed",
          chainId = ownerToken.chainId, address = ownerToken.address

      let temporaryMasterContractAddress = signalArgs.hash & "-master"
      let temporaryOwnerContractAddress = signalArgs.hash & "-owner"
      self.updateCommunityTokenCache(
        ownerToken.chainId, temporaryOwnerContractAddress, ownerToken
      )
      self.updateCommunityTokenCache(
        ownerToken.chainId, temporaryMasterContractAddress, masterToken
      )

      let data = OwnerTokenDeployedStatusArgs(
        communityId: ownerToken.communityId,
        chainId: ownerToken.chainId,
        ownerContractAddress: ownerToken.address,
        masterContractAddress: masterToken.address,
        deployState: deployState,
        transactionHash: signalArgs.hash,
      )
      self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOY_STATUS, data)
    except Exception as e:
      error "Error processing owner token deployment pending transaction event",
        msg = e.msg

  proc processCommunityTokenAction(
      self: Service, signalArgs: CommunityTokenActionSignal
  ) =
    case signalArgs.actionType
    of CommunityTokenActionType.Airdrop:
      self.refreshTokenHolders(signalArgs.communityToken)
    of CommunityTokenActionType.Burn:
      self.updateCommunityTokenCache(
        signalArgs.communityToken.chainId, signalArgs.communityToken.address,
        signalArgs.communityToken,
      )
      let data = RemoteDestructArgs(communityToken: signalArgs.communityToken)
      self.events.emit(SIGNAL_BURN_ACTION_RECEIVED, data)
    of CommunityTokenActionType.RemoteDestruct:
      self.refreshTokenHolders(signalArgs.communityToken)
    else:
      warn "Unknown token action", actionType = signalArgs.actionType

  proc init*(self: Service) =
    self.getAllCommunityTokensAsync()

    self.events.on(SignalType.Wallet.event) do(e: Args):
      var data = WalletSignal(e)
      if data.eventType == collectibles_backend.eventCommunityCollectiblesReceived:
        self.processReceivedCollectiblesWalletEvent(data.message, data.accounts)
      elif data.eventType == tokens_backend.eventCommunityTokenReceived:
        self.processReceivedCommunityTokenWalletEvent(data.message, data.accounts)

    self.events.on(SignalType.CommunityTokenAction.event) do(e: Args):
      let receivedData = CommunityTokenActionSignal(e)
      self.processCommunityTokenAction(receivedData)

    self.events.on(SignalType.CommunityTokenTransactionStatusChanged.event) do(e: Args):
      let receivedData = CommunityTokenTransactionStatusChangedSignal(e)
      if receivedData.errorString != "":
        error "Community token transaction has finished but the system error occured. Probably state of the token in database is broken.",
          errorString = receivedData.errorString,
          transactionHash = receivedData.hash,
          transactionSuccess = receivedData.success
      if receivedData.transactionType == $PendingTransactionTypeDto.SetSignerPublicKey:
        self.processSetSignerTransactionEvent(receivedData)
      elif receivedData.transactionType ==
          $PendingTransactionTypeDto.AirdropCommunityToken:
        self.processAirdropTransactionEvent(receivedData)
      elif receivedData.transactionType ==
          $PendingTransactionTypeDto.RemoteDestructCollectible:
        self.processRemoteDestructEvent(receivedData)
      elif receivedData.transactionType == $PendingTransactionTypeDto.BurnCommunityToken:
        self.processBurnEvent(receivedData)
      elif receivedData.transactionType ==
          $PendingTransactionTypeDto.DeployCommunityToken:
        self.processDeployCommunityToken(receivedData)
      elif receivedData.transactionType == $PendingTransactionTypeDto.DeployOwnerToken:
        self.processDeployOwnerToken(receivedData)

  proc buildTransactionDataDto(
      self: Service, addressFrom: string, chainId: int, contractAddress: string
  ): TransactionDataDto =
    let gasUnits = self.tempGasTable.getOrDefault((chainId, contractAddress), 0)
    let suggestedFees = self.tempFeeTable.getOrDefault(chainId, nil)
    if suggestedFees == nil:
      error "Can't find suggested fees for chainId", chainId = chainId
      return
    return ens_utils.buildTransactionDataDto(
      gasUnits, suggestedFees, addressFrom, chainId, contractAddress
    )

  proc temporaryMasterContractAddress*(ownerContractTransactionHash: string): string =
    return ownerContractTransactionHash & "-master"

  proc temporaryOwnerContractAddress*(ownerContractTransactionHash: string): string =
    return ownerContractTransactionHash & "-owner"

  proc deployOwnerContracts*(
      self: Service,
      communityId: string,
      addressFrom: string,
      password: string,
      ownerDeploymentParams: DeploymentParameters,
      masterDeploymentParams: DeploymentParameters,
      chainId: int,
  ) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, "")
      if txData.source == parseAddress(ZERO_ADDRESS):
        return

      # set my pub key as signer
      let signerPubKey = singletonInstance.userProfile.getPubKey()

      # deploy contract
      let response = tokens_backend.deployOwnerToken(
        chainId,
        %ownerDeploymentParams,
        %masterDeploymentParams,
        signerPubKey,
        %txData,
        common_utils.hashPassword(password),
      )
      let transactionHash = response.result["transactionHash"].getStr()
      let deployedOwnerToken = toCommunityTokenDto(response.result["ownerToken"])
      let deployedMasterToken = toCommunityTokenDto(response.result["masterToken"])
      debug "Deployment transaction hash ", transactionHash = transactionHash

      self.communityTokensCache.add(deployedOwnerToken)
      self.communityTokensCache.add(deployedMasterToken)

      let data = OwnerTokenDeploymentArgs(
        ownerToken: deployedOwnerToken,
        masterToken: deployedMasterToken,
        transactionHash: transactionHash,
      )
      self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOYMENT_STARTED, data)
    except RpcException:
      error "Error deploying owner contract", message = getCurrentExceptionMsg()
      let data = OwnerTokenDeployedStatusArgs(
        communityId: communityId, deployState: DeployState.Failed
      )
      self.events.emit(SIGNAL_OWNER_TOKEN_DEPLOY_STATUS, data)

  proc deployContract*(
      self: Service,
      communityId: string,
      addressFrom: string,
      password: string,
      deploymentParams: DeploymentParameters,
      chainId: int,
  ) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, "")
      if txData.source == parseAddress(ZERO_ADDRESS):
        return

      var response: RpcResponse[JsonNode]
      case deploymentParams.tokenType
      of TokenType.ERC721:
        response = tokens_backend.deployCollectibles(
          chainId, %deploymentParams, %txData, common_utils.hashPassword(password)
        )
      of TokenType.ERC20:
        response = tokens_backend.deployAssets(
          chainId, %deploymentParams, %txData, common_utils.hashPassword(password)
        )
      else:
        error "Contract deployment error - unknown token type",
          tokenType = deploymentParams.tokenType
        return

      let contractAddress = response.result["contractAddress"].getStr()
      let transactionHash = response.result["transactionHash"].getStr()
      let deployedCommunityToken =
        toCommunityTokenDto(response.result["communityToken"])
      debug "Deployed contract address ", contractAddress = contractAddress
      debug "Deployment transaction hash ", transactionHash = transactionHash

      # add to cache
      self.communityTokensCache.add(deployedCommunityToken)
      let data = CommunityTokenDeploymentArgs(
        communityToken: deployedCommunityToken, transactionHash: transactionHash
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOYMENT_STARTED, data)
    except RpcException:
      error "Error deploying contract", message = getCurrentExceptionMsg()
      let data = CommunityTokenDeployedStatusArgs(
        communityId: communityId, deployState: DeployState.Failed
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS, data)

  proc getCommunityTokens*(self: Service, communityId: string): seq[CommunityTokenDto] =
    return self.communityTokensCache.filter(x => (x.communityId == communityId))

  proc getAllCommunityTokens*(self: Service): seq[CommunityTokenDto] =
    return self.communityTokensCache

  proc getCommunityTokensDetailsAsync*(self: Service, communityId: string) =
    let arg = GetCommunityTokensDetailsArg(
      tptr: getCommunityTokensDetailsTaskArg,
      vptr: cast[uint](self.vptr),
      slot: "onCommunityTokensDetailsLoaded",
      communityId: communityId,
    )
    self.threadpool.start(arg)

  proc onCommunityTokensDetailsLoaded*(self: Service, response: string) {.slot.} =
    try:
      let responseJson = response.parseJson()

      if responseJson["error"].getStr != "":
        raise newException(ValueError, responseJson["error"].getStr)

      let communityTokens =
        parseCommunityTokens(responseJson["communityTokensResponse"]["result"])
      let communityTokenJsonItems = responseJson["communityTokenJsonItems"]

      self.events.emit(
        SIGNAL_COMMUNITY_TOKENS_DETAILS_LOADED,
        CommunityTokensDetailsArgs(
          communityId: responseJson["communityId"].getStr,
          communityTokens: communityTokens,
          communityTokenJsonItems: communityTokenJsonItems,
        ),
      )
    except Exception as e:
      error "Error getting community tokens details", message = e.msg

  proc getAllCommunityTokensAsync*(self: Service) =
    let arg = GetAllCommunityTokensArg(
      tptr: getAllCommunityTokensTaskArg,
      vptr: cast[uint](self.vptr),
      slot: "onGotAllCommunityTokens",
    )
    self.threadpool.start(arg)

  proc onGotAllCommunityTokens*(self: Service, response: string) {.slot.} =
    try:
      let responseJson = parseJson(response)
      self.communityTokensCache = map(
        responseJson["response"]["result"].getElems(),
        proc(x: JsonNode): CommunityTokenDto =
          x.toCommunityTokenDto(),
      )
    except RpcException as e:
      error "Error getting all community tokens async", message = e.msg

  proc removeCommunityToken*(
      self: Service, communityId: string, chainId: int, address: string
  ) =
    try:
      self.removeCommunityTokenAndUpdateCache(chainId, address)
      self.events.emit(
        SIGNAL_COMMUNITY_TOKEN_REMOVED,
        CommunityTokenRemovedArgs(
          communityId: communityId, contractAddress: address, chainId: chainId
        ),
      )
    except Exception as e:
      error "Error removing community token", message = e.msg
      self.events.emit(SIGNAL_REMOVE_COMMUNITY_TOKEN_FAILED, Args())

  proc getCommunityTokenBySymbol*(
      self: Service, communityId: string, symbol: string
  ): CommunityTokenDto =
    let communityTokens = self.getCommunityTokens(communityId)
    for token in communityTokens:
      if token.symbol == symbol:
        return token

  proc getCommunityToken*(
      self: Service, chainId: int, address: string
  ): CommunityTokenDto =
    let communityTokens = self.getAllCommunityTokens()
    for token in communityTokens:
      if token.chainId == chainId and token.address == address:
        return token

  proc getCommunityTokenDescription*(
      self: Service, chainId: int, address: string
  ): string =
    let communityTokens = self.getAllCommunityTokens()
    for token in communityTokens:
      if token.chainId == chainId and cmpIgnoreCase(token.address, address) == 0:
        return token.description
    return ""

  proc getCommunityTokenDescription*(
      self: Service, addressPerChain: seq[AddressPerChain]
  ): string =
    for apC in addressPerChain:
      let description = self.getCommunityTokenDescription(apC.chainId, apC.address)
      if not description.isEmptyOrWhitespace:
        return description
    return ""

  proc getCommunityTokenBurnState*(
      self: Service, chainId: int, contractAddress: string
  ): ContractTransactionStatus =
    let burnTransactions = self.transactionService.getPendingTransactionsForType(
      PendingTransactionTypeDto.BurnCommunityToken
    )
    for transaction in burnTransactions:
      try:
        if transaction.chainId == chainId and
            transaction.to.toLower == contractAddress.toLower:
          return ContractTransactionStatus.InProgress
      except Exception:
        discard
    return ContractTransactionStatus.Completed

  proc getRemoteDestructedAddresses*(
      self: Service, chainId: int, contractAddress: string
  ): seq[string] =
    try:
      let remoteDestructTransactions = self.transactionService.getPendingTransactionsForType(
        PendingTransactionTypeDto.RemoteDestructCollectible
      )
      for transaction in remoteDestructTransactions:
        if transaction.chainId == chainId and transaction.to == contractAddress:
          let burntAddresses = to(transaction.additionalData.parseJson(), seq[string])
          return burntAddresses
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

  proc getRemainingSupply*(
      self: Service, chainId: int, contractAddress: string
  ): Uint256 =
    let token = self.getCommunityToken(chainId, contractAddress)
    if token.deployState != DeployState.Deployed:
      return token.supply
    try:
      let response = tokens_backend.remainingSupply(chainId, contractAddress)
      return stint.parse(response.result.getStr(), Uint256)
    except RpcException:
      error "Error getting remaining supply", message = getCurrentExceptionMsg()
    # if there is an exception probably community token is not minted yet
    return token.supply

  proc getRemoteDestructedAmount*(
      self: Service, chainId: int, contractAddress: string
  ): Uint256 =
    try:
      let token = self.getCommunityToken(chainId, contractAddress)
      let tokenType = token.tokenType
      let tokenState = token.deployState
      if tokenType != TokenType.ERC721 or tokenState != DeployState.Deployed:
        return stint.parse("0", Uint256)
      let response = tokens_backend.remoteDestructedAmount(chainId, contractAddress)
      return stint.parse(response.result.getStr(), Uint256)
    except RpcException:
      error "Error getting remote destructed amount", message = getCurrentExceptionMsg()

  proc airdropTokens*(
      self: Service,
      communityId: string,
      password: string,
      collectiblesAndAmounts: seq[CommunityTokenAndAmount],
      walletAddresses: seq[string],
      addressFrom: string,
  ) =
    try:
      for collectibleAndAmount in collectiblesAndAmounts:
        let txData = self.buildTransactionDataDto(
          addressFrom, collectibleAndAmount.communityToken.chainId,
          collectibleAndAmount.communityToken.address,
        )
        if txData.source == parseAddress(ZERO_ADDRESS):
          return
        debug "Airdrop tokens ",
          chainId = collectibleAndAmount.communityToken.chainId,
          address = collectibleAndAmount.communityToken.address,
          amount = collectibleAndAmount.amount
        let response = tokens_backend.mintTokens(
          collectibleAndAmount.communityToken.chainId,
          collectibleAndAmount.communityToken.address,
          %txData,
          common_utils.hashPassword(password),
          walletAddresses,
          collectibleAndAmount.amount,
        )
        let transactionHash = response.result.getStr()
        debug "Airdrop transaction hash ", transactionHash = transactionHash

        var data = AirdropArgs(
          communityToken: collectibleAndAmount.communityToken,
          transactionHash: transactionHash,
          status: ContractTransactionStatus.InProgress,
        )
        self.events.emit(SIGNAL_AIRDROP_STATUS, data)
    except RpcException:
      error "Error airdropping tokens", message = getCurrentExceptionMsg()

  proc computeAirdropFee*(
      self: Service,
      collectiblesAndAmounts: seq[CommunityTokenAndAmount],
      walletAddresses: seq[string],
      addressFrom: string,
      requestId: string,
  ) =
    try:
      self.tempTokensAndAmounts = collectiblesAndAmounts
      let arg = AsyncGetMintFees(
        tptr: asyncGetMintFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onAirdropFees",
        collectiblesAndAmounts: collectiblesAndAmounts,
        walletAddresses: walletAddresses,
        addressFrom: addressFrom,
        requestId: requestId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading airdrop fees", msg = e.msg
      var dataToEmit = AirdropFeesArgs()
      dataToEmit.errorCode = ComputeFeeErrorCode.Other
      self.events.emit(SIGNAL_COMPUTE_AIRDROP_FEE, dataToEmit)

  proc getFiatValue(self: Service, cryptoBalance: float, cryptoSymbol: string): float =
    if (cryptoSymbol == ""):
      return 0.0
    let price = self.tokenService.getPriceBySymbol(cryptoSymbol)
    return cryptoBalance * price

  proc findContractByUniqueId*(
      self: Service, contractUniqueKey: string
  ): CommunityTokenDto =
    let allTokens = self.getAllCommunityTokens()
    for token in allTokens:
      if common_utils.contractUniqueKey(token.chainId, token.address) ==
          contractUniqueKey:
        return token

  proc computeDeployFee*(
      self: Service,
      chainId: int,
      accountAddress: string,
      tokenType: TokenType,
      requestId: string,
  ) =
    try:
      if tokenType != TokenType.ERC20 and tokenType != TokenType.ERC721:
        error "Error loading fees: unknown token type", tokenType = tokenType
        return
      let arg = AsyncGetDeployFeesArg(
        tptr: asyncGetDeployFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onDeployFees",
        chainId: chainId,
        addressFrom: accountAddress,
        tokenType: tokenType,
        requestId: requestId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg

  proc computeSetSignerFee*(
      self: Service,
      chainId: int,
      contractAddress: string,
      accountAddress: string,
      requestId: string,
  ) =
    try:
      let arg = AsyncSetSignerFeesArg(
        tptr: asyncSetSignerFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onSetSignerFees",
        chainId: chainId,
        contractAddress: contractAddress,
        addressFrom: accountAddress,
        requestId: requestId,
        newSignerPubKey: singletonInstance.userProfile.getPubKey(),
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg

  proc computeDeployOwnerContractsFee*(
      self: Service,
      chainId: int,
      accountAddress: string,
      communityId: string,
      ownerDeploymentParams: DeploymentParameters,
      masterDeploymentParams: DeploymentParameters,
      requestId: string,
  ) =
    try:
      let arg = AsyncDeployOwnerContractsFeesArg(
        tptr: asyncGetDeployOwnerContractsFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onDeployOwnerContractsFees",
        chainId: chainId,
        addressFrom: accountAddress,
        requestId: requestId,
        signerPubKey: singletonInstance.userProfile.getPubKey(),
        communityId: communityId,
        ownerParams: %ownerDeploymentParams,
        masterParams: %masterDeploymentParams,
      )
      self.threadpool.start(arg)
    except Exception as e:
      #TODO: handle error - emit error signal
      error "Error loading fees", msg = e.msg

  proc getOwnerBalances(
      self: Service,
      contractOwners: seq[CommunityCollectibleOwner],
      ownerAddress: string,
  ): seq[CollectibleBalance] =
    for owner in contractOwners:
      if owner.collectibleOwner.address == ownerAddress:
        return owner.collectibleOwner.balances

  proc collectTokensToBurn(
      self: Service,
      walletAndAmountList: seq[WalletAndAmount],
      contractOwners: seq[CommunityCollectibleOwner],
  ): seq[UInt256] =
    if len(walletAndAmountList) == 0 or len(contractOwners) == 0:
      return
    for walletAndAmount in walletAndAmountList:
      let ownerBalances =
        self.getOwnerBalances(contractOwners, walletAndAmount.walletAddress)
      let amount = walletAndAmount.amount
      if amount > len(ownerBalances):
        error "amount to burn is higher than the number of tokens",
          amount = amount,
          balance = len(ownerBalances),
          owner = walletAndAmount.walletAddress
        return
      for i in 0 .. amount - 1: # add the amount of tokens
        result.add(ownerBalances[i].tokenId)

  proc getTokensToBurn(
      self: Service,
      walletAndAmountList: seq[WalletAndAmount],
      contract: CommunityTokenDto,
  ): seq[Uint256] =
    if contract.address == "":
      error "Can't find contract"
      return
    let tokenOwners = self.getCommunityTokenOwners(
      contract.communityId, contract.chainId, contract.address
    )
    let tokenIds = self.collectTokensToBurn(walletAndAmountList, tokenOwners)
    if len(tokenIds) == 0:
      error "Can't find token ids to burn"
    return tokenIds

  proc selfDestructCollectibles*(
      self: Service,
      communityId: string,
      password: string,
      walletAndAmounts: seq[WalletAndAmount],
      contractUniqueKey: string,
      addressFrom: string,
  ) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let tokenIds = self.getTokensToBurn(walletAndAmounts, contract)
      if len(tokenIds) == 0:
        debug "No token ids to remote burn", walletAndAmounts = walletAndAmounts
        return
      var addresses: seq[string] = @[]
      for walletAndAmount in walletAndAmounts:
        addresses.add(walletAndAmount.walletAddress)
      let txData =
        self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Remote destruct collectibles ",
        chainId = contract.chainId, address = contract.address, tokens = tokenIds
      let response = tokens_backend.remoteBurn(
        contract.chainId,
        contract.address,
        %txData,
        common_utils.hashPassword(password),
        tokenIds,
        $(%addresses),
      )
      let transactionHash = response.result.getStr()
      debug "Remote destruct transaction hash ", transactionHash = transactionHash

      var data = RemoteDestructArgs(
        communityToken: contract,
        transactionHash: transactionHash,
        status: ContractTransactionStatus.InProgress,
        remoteDestructAddresses: addresses,
      )
      self.events.emit(SIGNAL_REMOTE_DESTRUCT_STATUS, data)
    except Exception as e:
      error "Remote self destruct error", msg = e.msg

  proc computeSelfDestructFee*(
      self: Service,
      walletAndAmountList: seq[WalletAndAmount],
      contractUniqueKey: string,
      addressFrom: string,
      requestId: string,
  ) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let tokenIds = self.getTokensToBurn(walletAndAmountList, contract)
      if len(tokenIds) == 0:
        warn "token list is empty"
        return
      let arg = AsyncGetRemoteBurnFees(
        tptr: asyncGetRemoteBurnFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onSelfDestructFees",
        chainId: contract.chainId,
        contractAddress: contract.address,
        tokenIds: tokenIds,
        addressFrom: addressFrom,
        requestId: requestId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading fees", msg = e.msg

  proc create0CurrencyAmounts(self: Service): (CurrencyAmount, CurrencyAmount) =
    let ethCurrency = newCurrencyAmount(0.0, ethSymbol, 1, false)
    let fiatCurrency =
      newCurrencyAmount(0.0, self.settingsService.getCurrency(), 1, false)
    return (ethCurrency, fiatCurrency)

  proc createCurrencyAmounts(
      self: Service, ethValue: float64, fiatValue: float64
  ): (CurrencyAmount, CurrencyAmount) =
    let ethCurrency = newCurrencyAmount(ethValue, ethSymbol, 4, false)
    let fiatCurrency =
      newCurrencyAmount(fiatValue, self.settingsService.getCurrency(), 2, false)
    return (ethCurrency, fiatCurrency)

  proc getErrorCodeFromMessage(
      self: Service, errorMessage: string
  ): ComputeFeeErrorCode =
    var errorCode = ComputeFeeErrorCode.Other
    if errorMessage.contains("403 Forbidden") or errorMessage.contains("exceed"):
      errorCode = ComputeFeeErrorCode.Infura
    if errorMessage.contains("execution reverted"):
      errorCode = ComputeFeeErrorCode.Revert
    return errorCode

  proc burnTokens*(
      self: Service,
      communityId: string,
      password: string,
      contractUniqueKey: string,
      amount: Uint256,
      addressFrom: string,
  ) =
    try:
      var contract = self.findContractByUniqueId(contractUniqueKey)
      let txData =
        self.buildTransactionDataDto(addressFrom, contract.chainId, contract.address)
      debug "Burn tokens ",
        chainId = contract.chainId, address = contract.address, amount = amount
      let response = tokens_backend.burn(
        contract.chainId,
        contract.address,
        %txData,
        common_utils.hashPassword(password),
        amount,
      )
      let transactionHash = response.result.getStr()
      debug "Burn transaction hash ", transactionHash = transactionHash

      var data = RemoteDestructArgs(
        communityToken: contract,
        transactionHash: transactionHash,
        status: ContractTransactionStatus.InProgress,
      )
      self.events.emit(SIGNAL_BURN_STATUS, data)
    except Exception as e:
      error "Burn error", msg = e.msg

  proc setSigner*(
      self: Service,
      password: string,
      communityId: string,
      chainId: int,
      contractAddress: string,
      addressFrom: string,
  ) =
    try:
      let txData = self.buildTransactionDataDto(addressFrom, chainId, contractAddress)
      debug "Set signer ", chainId = chainId, address = contractAddress
      let signerPubKey = singletonInstance.userProfile.getPubKey()
      let response = tokens_backend.setSignerPubKey(
        chainId,
        contractAddress,
        %txData,
        signerPubKey,
        common_utils.hashPassword(password),
      )
      let transactionHash = response.result.getStr()
      debug "Set signer transaction hash ", transactionHash = transactionHash

      let data = SetSignerArgs(
        status: ContractTransactionStatus.InProgress,
        chainId: chainId,
        transactionHash: transactionHash,
        communityId: communityId,
      )

      self.events.emit(SIGNAL_SET_SIGNER_STATUS, data)

      # observe transaction state
      let contractDetails = ContractDetails(
        chainId: chainId, contractAddress: contractAddress, communityId: communityId
      )
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

  proc computeBurnFee*(
      self: Service,
      contractUniqueKey: string,
      amount: Uint256,
      addressFrom: string,
      requestId: string,
  ) =
    try:
      let contract = self.findContractByUniqueId(contractUniqueKey)
      let arg = AsyncGetBurnFees(
        tptr: asyncGetBurnFeesTask,
        vptr: cast[uint](self.vptr),
        slot: "onBurnFees",
        chainId: contract.chainId,
        contractAddress: contract.address,
        amount: amount,
        addressFrom: addressFrom,
        requestId: requestId,
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading burn fees", msg = e.msg

  proc createComputeFeeArgsWithError(
      self: Service, errorMessage: string
  ): ComputeFeeArgs =
    let errorCode = self.getErrorCodeFromMessage(errorMessage)
    let (ethCurrency, fiatCurrency) = self.create0CurrencyAmounts()
    return ComputeFeeArgs(
      ethCurrency: ethCurrency, fiatCurrency: fiatCurrency, errorCode: errorCode
    )

  # Returns eth value with l1 fee included
  proc computeEthValue(
      self: Service, gasUnits: int, suggestedFees: SuggestedFeesDto
  ): float =
    try:
      let maxFees = suggestedFees.maxFeePerGasM
      let gasPrice =
        if suggestedFees.eip1559Enabled: maxFees else: suggestedFees.gasPrice

      let weiValue = gwei2Wei(gasPrice) * gasUnits.u256
      let l1FeeInWei = gwei2Wei(suggestedFees.l1GasFee)
      let ethValueStr = wei2Eth(weiValue + l1FeeInWei)
      return parseFloat(ethValueStr)
    except Exception as e:
      error "Error computing eth value", msg = e.msg

  proc getWalletBalanceForChain(
      self: Service, walletAddress: string, chainId: int
  ): float =
    var balance = 0.0
    let tokens = self.walletAccountService.getGroupedAccountsAssetsList()
    for token in tokens:
      if token.symbol == ethSymbol:
        let balances = token.balancesPerAccount
          .filter(
            balanceItem =>
              balanceItem.account == walletAddress.toLower() and
              balanceItem.chainId == chainId
          )
          .map(b => b.balance)
        for b in balances:
          balance +=
            self.currencyService.parseCurrencyValueByTokensKey(token.tokensKey, b)
    return balance

  proc createComputeFeeArgsFromEthAndBalance(
      self: Service, ethValue: float, balance: float
  ): ComputeFeeArgs =
    let fiatValue = self.getFiatValue(ethValue, ethSymbol)
    let (ethCurrency, fiatCurrency) = self.createCurrencyAmounts(ethValue, fiatValue)
    return ComputeFeeArgs(
      ethCurrency: ethCurrency,
      fiatCurrency: fiatCurrency,
      errorCode: (
        if ethValue > balance: ComputeFeeErrorCode.Balance
        else: ComputeFeeErrorCode.Success
      ),
    )

  proc createComputeFeeArgs(
      self: Service,
      gasUnits: int,
      suggestedFees: SuggestedFeesDto,
      chainId: int,
      walletAddress: string,
  ): ComputeFeeArgs =
    let ethValue = self.computeEthValue(gasUnits, suggestedFees)
    let balance = self.getWalletBalanceForChain(walletAddress, chainId)
    debug "computing fees",
      walletBalance = balance,
      ethValueWithL1Fee = ethValue,
      l1Fee = gwei2Eth(suggestedFees.l1GasFee)
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

  proc parseFeeResponseAndEmitSignal(
      self: Service, response: string, signalName: string
  ) =
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
      let data =
        self.createComputeFeeArgs(gasUnits, suggestedFees, chainId, addressFrom)
      data.requestId = responseJson{"requestId"}.getStr
      self.events.emit(signalName, data)
    except Exception:
      error "Error creating fee args", message = getCurrentExceptionMsg()
      let data = self.createComputeFeeArgsWithError(getCurrentExceptionMsg())
      data.requestId = responseJson{"requestId"}.getStr
      self.events.emit(signalName, data)

  proc onDeployOwnerContractsFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_DEPLOY_FEE)

  proc onSelfDestructFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_SELF_DESTRUCT_FEE)

  proc onBurnFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_BURN_FEE)

  proc onDeployFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_DEPLOY_FEE)

  proc onSetSignerFees*(self: Service, response: string) {.slot.} =
    self.parseFeeResponseAndEmitSignal(response, SIGNAL_COMPUTE_SET_SIGNER_FEE)

  proc onAirdropFees*(self: Service, response: string) {.slot.} =
    var wholeEthCostForChainWallet: Table[ChainWalletTuple, float]
    var ethValuesForContracts: Table[ContractTuple, float]
    var allComputeFeeArgs: seq[ComputeFeeArgs]
    var dataToEmit = AirdropFeesArgs()
    dataToEmit.errorCode = ComputeFeeErrorCode.Success
    let responseJson = response.parseJson()

    try:
      let errorMessage = responseJson{"error"}.getStr
      let requestId = responseJson{"requestId"}.getStr
      if errorMessage != "":
        for collectibleAndAmount in self.tempTokensAndAmounts:
          let args = self.createComputeFeeArgsWithError(errorMessage)
          args.contractUniqueKey = common_utils.contractUniqueKey(
            collectibleAndAmount.communityToken.chainId,
            collectibleAndAmount.communityToken.address,
          )
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
        let gasUnits = self.tempGasTable[
          (
            collectibleAndAmount.communityToken.chainId,
            collectibleAndAmount.communityToken.address,
          )
        ]
        let suggestedFees =
          self.tempFeeTable[collectibleAndAmount.communityToken.chainId]
        let ethValue = self.computeEthValue(gasUnits, suggestedFees)

        wholeEthCostForChainWallet[
          (collectibleAndAmount.communityToken.chainId, addressFrom)
        ] =
          wholeEthCostForChainWallet.getOrDefault(
            (collectibleAndAmount.communityToken.chainId, addressFrom), 0.0
          ) + ethValue

        ethValuesForContracts[
          (
            collectibleAndAmount.communityToken.chainId,
            collectibleAndAmount.communityToken.address,
          )
        ] = ethValue

      var totalEthVal = 0.0
      var totalFiatVal = 0.0
      # for every contract create cost Args
      for collectibleAndAmount in self.tempTokensAndAmounts:
        let contractTuple = (
          chainId: collectibleAndAmount.communityToken.chainId,
          address: collectibleAndAmount.communityToken.address,
        )
        let ethValue = ethValuesForContracts[contractTuple]
        var balance = self.getWalletBalanceForChain(addressFrom, contractTuple.chainId)
        if balance < wholeEthCostForChainWallet[(contractTuple.chainId, addressFrom)]:
          # if wallet balance for this chain is less than the whole cost
          # then we can't afford it; setting balance to 0.0 will set balance error code in Args
          balance = 0.0
          dataToEmit.errorCode = ComputeFeeErrorCode.Balance
            # set total error code to balance error
        var args = self.createComputeFeeArgsFromEthAndBalance(ethValue, balance)
        totalEthVal = totalEthVal + ethValue
        totalFiatVal = totalFiatVal + args.fiatCurrency.getAmount()
        args.contractUniqueKey = common_utils.contractUniqueKey(
          collectibleAndAmount.communityToken.chainId,
          collectibleAndAmount.communityToken.address,
        )
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

  proc isTokenDeployed(self: Service, token: CommunityTokenDto): bool =
    return token.deployState == DeployState.Deployed

  proc fetchCommunityOwners(self: Service, communityToken: CommunityTokenDto) =
    if not self.isTokenDeployed(communityToken):
      return

    if communityToken.tokenType == TokenType.ERC20:
      let arg = FetchAssetOwnersArg(
        tptr: fetchAssetOwnersTaskArg,
        vptr: cast[uint](self.vptr),
        slot: "onCommunityTokenOwnersFetched",
        chainId: communityToken.chainId,
        contractAddress: communityToken.address,
        communityId: communityToken.communityId,
      )
      self.threadpool.start(arg)
      return
    elif communityToken.tokenType == TokenType.ERC721:
      let arg = FetchCollectibleOwnersArg(
        tptr: fetchCollectibleOwnersTaskArg,
        vptr: cast[uint](self.vptr),
        slot: "onCommunityTokenOwnersFetched",
        chainId: communityToken.chainId,
        contractAddress: communityToken.address,
        communityId: communityToken.communityId,
      )
      self.threadpool.start(arg)
      return
    else:
      debug "Unable to fetch token hodlers for token type ",
        token = communityToken.tokenType

  proc onCommunityTokenOwnersFetched*(self: Service, response: string) {.slot.} =
    let responseJson = response.parseJson()
    let chainId = responseJson{"chainId"}.getInt
    let contractAddress = responseJson{"contractAddress"}.getStr
    let communityId = responseJson{"communityId"}.getStr

    try:
      if responseJson{"error"}.kind != JNull and responseJson{"error"}.getStr != "":
        raise newException(ValueError, responseJson["error"].getStr)

      let communityTokenOwners = toCommunityCollectibleOwners(responseJson{"result"})
      self.tokenOwnersCache[(chainId, contractAddress)] = communityTokenOwners
      let data = CommunityTokenOwnersArgs(
        chainId: chainId,
        contractAddress: contractAddress,
        communityId: communityId,
        owners: communityTokenOwners,
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_OWNERS_FETCHED, data)
    except Exception as e:
      error "Can't fetch community token owners",
        chainId = responseJson{"chainId"},
        contractAddress = responseJson{"contractAddress"},
        errorMsg = e.msg

      let data = CommunityTokenOwnersArgs(
        chainId: chainId,
        contractAddress: contractAddress,
        communityId: communityId,
        error: e.msg,
      )
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_OWNERS_LOADING_FAILED, data)

    # restart token holders timer
    self.restartTokenHoldersTimer(chainId, contractAddress)

  # get owners from cache
  proc getCommunityTokenOwners*(
      self: Service, communityId: string, chainId: int, contractAddress: string
  ): seq[CommunityCollectibleOwner] =
    return
      self.tokenOwnersCache.getOrDefault((chainId: chainId, address: contractAddress))

  proc iAmCommunityPrivilegedUser(self: Service, communityId: string): bool =
    let community = self.communityService.getCommunityById(communityId)
    return community.isPrivilegedUser()

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
    let notification = self.acService.getNotificationForTypeAndCommunityId(
      notification.ActivityCenterNotificationType.OwnerTokenReceived, communityId
    )
    if notification != nil:
      discard self.acService.deleteActivityCenterNotifications(@[notification.id])
    try:
      let response = tokens_backend.registerSetSignerDeclinedNotification(communityId)
      checkAndEmitACNotificationsFromResponse(
        self.events, response.result{"activityCenterNotifications"}
      )
    except Exception as e:
      error "Error registering decline set signer notification", msg = e.msg
    let finaliseStatusArgs =
      FinaliseOwnershipStatusArgs(isPending: false, communityId: communityId)
    self.events.emit(SIGNAL_FINALISE_OWNERSHIP_STATUS, finaliseStatusArgs)

  proc asyncGetOwnerTokenOwnerAddress*(
      self: Service, chainId: int, contractAddress: string
  ) =
    let arg = GetOwnerTokenOwnerAddressArgs(
      tptr: getOwnerTokenOwnerAddressTask,
      vptr: cast[uint](self.vptr),
      slot: "onGetOwnerTokenOwner",
      chainId: chainId,
      contractAddress: contractAddress,
    )
    self.threadpool.start(arg)

  proc onGetOwnerTokenOwner*(self: Service, response: string) {.slot.} =
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

  proc refreshCommunityToken*(self: Service, chainId: int, contractAddress: string) =
    try:
      discard
        tokens_backend.reTrackOwnerTokenDeploymentTransaction(chainId, contractAddress)
    except Exception:
      error "can't retrack token transaction", message = getCurrentExceptionMsg()

  # ran also when holders are fetched
  proc restartTokenHoldersTimer(self: Service, chainId: int, contractAddress: string) =
    if not self.tokenHoldersManagementStarted:
      return
    self.tokenHoldersTimer.stop()

    let tokenTupleKey = (chainId: chainId, address: contractAddress)
    var nextTimerShotInSeconds = int64(0)
    if self.tokenHoldersLastUpdateMap.hasKey(tokenTupleKey):
      let lastUpdateTime = self.tokenHoldersLastUpdateMap[tokenTupleKey]
      const intervalInSecs = int64(5 * 60)
      let nowInSeconds = now().toTime().toUnix()
      nextTimerShotInSeconds = intervalInSecs - (nowInSeconds - lastUpdateTime)
      if nextTimerShotInSeconds < 0:
        nextTimerShotInSeconds = 0

    self.tokenHoldersTimer.setInterval(int(nextTimerShotInSeconds * 1000))
    self.tokenHoldersTimer.start()

  # executed when Token page with holders is opened
  proc startTokenHoldersManagement*(
      self: Service, chainId: int, contractAddress: string
  ) =
    let communityToken = self.getCommunityToken(chainId, contractAddress)
    if not self.iAmCommunityPrivilegedUser(communityToken.communityId):
      warn "can't get token holders - not privileged user"
      return

    self.tokenHoldersToken = communityToken
    self.tokenHoldersManagementStarted = true
    self.restartTokenHoldersTimer(chainId, contractAddress)

  # executed when Token page with holders is closed
  proc stopTokenHoldersManagement*(self: Service) =
    self.tokenHoldersManagementStarted = false
    self.tokenHoldersTimer.stop()

  proc onTokenHoldersTimeout(self: Service) {.slot.} =
    # update last fetch time
    let tokenTupleKey =
      (chainId: self.tokenHoldersToken.chainId, address: self.tokenHoldersToken.address)
    let nowInSeconds = now().toTime().toUnix()
    self.tokenHoldersLastUpdateMap[tokenTupleKey] = nowInSeconds
    # run async calls to fetch holders
    self.fetchCommunityOwners(self.tokenHoldersToken)

  # executed when there was some change and holders needs to be fetched again
  proc refreshTokenHolders(self: Service, token: CommunityTokenDto) =
    let tokenTupleKey = (chainId: token.chainId, address: token.address)
    self.tokenHoldersLastUpdateMap.del(tokenTupleKey)
    if not self.tokenHoldersManagementStarted:
      # not need to get holders now
      return
    let holdersTokenTuple =
      (chainId: self.tokenHoldersToken.chainId, address: self.tokenHoldersToken.address)
    if (tokenTupleKey != holdersTokenTuple):
      # different token is opened now
      return
    self.restartTokenHoldersTimer(token.chainId, token.address)
