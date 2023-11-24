import stint
import ./io_interface as community_tokens_module_interface

import app_service/service/community_tokens/service as community_tokens_service
import app_service/service/transaction/service as transaction_service
import app_service/service/network/service as networks_service
import app_service/service/community/service as community_service
import app_service/common/types
import app/core/signals/types
import app/core/eventemitter
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module


const UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER* = "communityTokensModule-DeployCollectibles"

type
  Controller* = ref object of RootObj
    communityTokensModule: community_tokens_module_interface.AccessInterface
    events: EventEmitter
    communityTokensService: community_tokens_service.Service
    transactionService: transaction_service.Service
    networksService: networks_service.Service
    communityService: community_service.Service

proc newCommunityTokensController*(
    communityTokensModule: community_tokens_module_interface.AccessInterface,
    events: EventEmitter,
    communityTokensService: community_tokens_service.Service,
    transactionService: transaction_service.Service,
    networksService: networks_service.Service,
    communityService: community_service.Service
    ): Controller =
  result = Controller()
  result.communityTokensModule = communityTokensModule
  result.events = events
  result.communityTokensService = communityTokensService
  result.transactionService = transactionService
  result.networksService = networksService
  result.communityService = communityService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER:
      return
    self.communityTokensModule.onUserAuthenticated(args.password)
  self.events.on(SIGNAL_COMPUTE_DEPLOY_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onDeployFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode, args.requestId)
  self.events.on(SIGNAL_COMPUTE_SELF_DESTRUCT_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onSelfDestructFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode, args.requestId)
  self.events.on(SIGNAL_COMPUTE_BURN_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onBurnFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode, args.requestId)
  self.events.on(SIGNAL_COMPUTE_SET_SIGNER_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onSetSignerFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode, args.requestId)
  self.events.on(SIGNAL_COMPUTE_AIRDROP_FEE) do(e:Args):
    let args = AirdropFeesArgs(e)
    self.communityTokensModule.onAirdropFeesComputed(args)
  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOYMENT_STARTED) do(e: Args):
    let args = CommunityTokenDeploymentArgs(e)
    self.communityTokensModule.onCommunityTokenDeployStateChanged(args.communityToken.communityId, args.communityToken.chainId, args.transactionHash, args.communityToken.deployState)
  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS) do(e: Args):
    let args = OwnerTokenDeployedStatusArgs(e)
    self.communityTokensModule.onCommunityTokenDeployStateChanged(args.communityId, args.chainId, args.transactionHash, args.deployState)
  self.events.on(SIGNAL_OWNER_TOKEN_DEPLOYMENT_STARTED) do(e: Args):
    let args = OwnerTokenDeploymentArgs(e)
    self.communityTokensModule.onOwnerTokenDeployStarted(args.ownerToken.communityId, args.ownerToken.chainId, args.transactionHash)
  self.events.on(SIGNAL_OWNER_TOKEN_DEPLOY_STATUS) do(e: Args):
    let args = OwnerTokenDeployedStatusArgs(e)
    self.communityTokensModule.onOwnerTokenDeployStateChanged(args.communityId, args.chainId, args.transactionHash, args.deployState)
  self.events.on(SIGNAL_REMOTE_DESTRUCT_STATUS) do(e: Args):
    let args = RemoteDestructArgs(e)
    self.communityTokensModule.onRemoteDestructStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_BURN_STATUS) do(e: Args):
    let args = RemoteDestructArgs(e)
    self.communityTokensModule.onBurnStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_AIRDROP_STATUS) do(e: Args):
    let args = AirdropArgs(e)
    self.communityTokensModule.onAirdropStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_OWNER_TOKEN_RECEIVED) do(e: Args):
    let args = OwnerTokenReceivedArgs(e)
    self.communityTokensModule.onOwnerTokenReceived(args.communityId, args.communityName, args.chainId, args.contractAddress)
  self.events.on(SIGNAL_SET_SIGNER_STATUS) do(e: Args):
    let args = SetSignerArgs(e)
    self.communityTokensModule.onSetSignerStateChanged(args.communityId, args.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_COMMUNITY_LOST_OWNERSHIP) do(e: Args):
    let args = CommunityIdArgs(e)
    self.communityTokensModule.onLostOwnership(args.communityId)
  self.events.on(SIGNAL_OWNER_TOKEN_OWNER_ADDRESS) do(e: Args):
    let args = OwnerTokenOwnerAddressArgs(e)
    self.communityTokensModule.onOwnerTokenOwnerAddress(args.chainId, args.contractAddress, args.address, args.addressName)
  self.events.on(SIGNAL_OWNER_TOKEN_SENT) do(e: Args):
    let args = OwnerTokenSentArgs(e)
    self.communityTokensModule.onSendOwnerTokenStateChanged(args.chainId, args.txHash, args.tokenName, args.status)

proc deployContract*(self: Controller, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, tokenImageCropInfoJson: string, chainId: int) =
  self.communityTokensService.deployContract(communityId, addressFrom, password, deploymentParams, tokenMetadata, tokenImageCropInfoJson, chainId)

proc deployOwnerContracts*(self: Controller, communityId: string, addressFrom: string, password: string,
      ownerDeploymentParams: DeploymentParameters, ownerTokenMetadata: CommunityTokensMetadataDto,
      masterDeploymentParams: DeploymentParameters, masterTokenMetadata: CommunityTokensMetadataDto,
      tokenImageCropInfoJson: string, chainId: int) =
  self.communityTokensService.deployOwnerContracts(communityId, addressFrom, password, ownerDeploymentParams, ownerTokenMetadata,
      masterDeploymentParams, masterTokenMetadata, tokenImageCropInfoJson, chainId)

proc removeCommunityToken*(self: Controller, communityId: string, chainId: int, address: string) =
  self.communityTokensService.removeCommunityToken(communityId, chainId, address)

proc airdropTokens*(self: Controller, communityId: string, password: string, tokensAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string], addressFrom: string) =
  self.communityTokensService.airdropTokens(communityId, password, tokensAndAmounts, walletAddresses, addressFrom)

proc computeAirdropFee*(self: Controller, tokensAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string], addressFrom: string, requestId: string) =
  self.communityTokensService.computeAirdropFee(tokensAndAmounts, walletAddresses, addressFrom, requestId)

proc selfDestructCollectibles*(self: Controller, communityId: string, password: string, walletAndAmounts: seq[WalletAndAmount], contractUniqueKey: string, addressFrom: string) =
  self.communityTokensService.selfDestructCollectibles(communityId, password, walletAndAmounts, contractUniqueKey, addressFrom)

proc burnTokens*(self: Controller, communityId: string, password: string, contractUniqueKey: string, amount: Uint256, addressFrom: string) =
  self.communityTokensService.burnTokens(communityId, password, contractUniqueKey, amount, addressFrom)

proc setSigner*(self: Controller, password: string, communityId: string, chainId: int, contractAddress: string, addressFrom: string) =
  self.communityTokensService.setSigner(password, communityId, chainId, contractAddress, addressFrom)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  return self.communityTokensService.getCommunityTokens(communityId)

proc computeDeployFee*(self: Controller, chainId: int, accountAddress: string, tokenType: TokenType, requestId: string) =
  self.communityTokensService.computeDeployFee(chainId, accountAddress, tokenType, requestId)

proc computeSetSignerFee*(self: Controller, chainId: int, contractAddress: string, addressFrom: string, requestId: string) =
  self.communityTokensService.computeSetSignerFee(chainId, contractAddress, addressFrom, requestId)

proc computeDeployOwnerContractsFee*(self: Controller, chainId: int, accountAddress: string, communityId: string, ownerDeploymentParams: DeploymentParameters, masterDeploymentParams: DeploymentParameters, requestId: string) =
  self.communityTokensService.computeDeployOwnerContractsFee(chainId, accountAddress, communityId, ownerDeploymentParams, masterDeploymentParams, requestId)

proc computeSelfDestructFee*(self: Controller, walletAndAmountList: seq[WalletAndAmount], contractUniqueKey: string, addressFrom: string, requestId: string) =
  self.communityTokensService.computeSelfDestructFee(walletAndAmountList, contractUniqueKey, addressFrom, requestId)

proc findContractByUniqueId*(self: Controller, contractUniqueKey: string): CommunityTokenDto =
  return self.communityTokensService.findContractByUniqueId(contractUniqueKey)

proc computeBurnFee*(self: Controller, contractUniqueKey: string, amount: Uint256, addressFrom: string, requestId: string) =
  self.communityTokensService.computeBurnFee(contractUniqueKey, amount, addressFrom, requestId)

proc getNetwork*(self:Controller, chainId: int): NetworkDto =
  self.networksService.getNetwork(chainId)

proc getOwnerToken*(self: Controller, communityId: string): CommunityTokenDto =
  return self.communityTokensService.getOwnerToken(communityId)

proc getTokenMasterToken*(self: Controller, communityId: string): CommunityTokenDto =
  return self.communityTokensService.getTokenMasterToken(communityId)

proc getCommunityById*(self: Controller, communityId: string): CommunityDto =
  return self.communityService.getCommunityById(communityId)

proc declineOwnership*(self: Controller, communityId: string) =
  self.communityTokensService.declineOwnership(communityId)

proc asyncGetOwnerTokenOwnerAddress*(self: Controller, chainId: int, contractAddress: string) =
  self.communityTokensService.asyncGetOwnerTokenOwnerAddress(chainId, contractAddress)
