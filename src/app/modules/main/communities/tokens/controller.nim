import ./io_interface as community_tokens_module_interface

import ../../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/network/service as networks_service
import ../../../../../app_service/service/community/dto/community
import ../../../../core/signals/types
import ../../../../core/eventemitter
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module


const UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER* = "communityTokensModule-DeployCollectibles"

type
  Controller* = ref object of RootObj
    communityTokensModule: community_tokens_module_interface.AccessInterface
    events: EventEmitter
    communityTokensService: community_tokens_service.Service
    transactionService: transaction_service.Service
    networksService: networks_service.Service

proc newCommunityTokensController*(
    communityTokensModule: community_tokens_module_interface.AccessInterface,
    events: EventEmitter,
    communityTokensService: community_tokens_service.Service,
    transactionService: transaction_service.Service,
    networksService: networks_service.Service
    ): Controller =
  result = Controller()
  result.communityTokensModule = communityTokensModule
  result.events = events
  result.communityTokensService = communityTokensService
  result.transactionService = transactionService
  result.networksService = networksService

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
    self.communityTokensModule.onDeployFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode)
  self.events.on(SIGNAL_COMPUTE_SELF_DESTRUCT_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onSelfDestructFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode)
  self.events.on(SIGNAL_COMPUTE_BURN_FEE) do(e:Args):
    let args = ComputeFeeArgs(e)
    self.communityTokensModule.onBurnFeeComputed(args.ethCurrency, args.fiatCurrency, args.errorCode)
  self.events.on(SIGNAL_COMPUTE_AIRDROP_FEE) do(e:Args):
    let args = AirdropFeesArgs(e)
    self.communityTokensModule.onAirdropFeesComputed(args)
  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOYED) do(e: Args):
    let args = CommunityTokenDeployedArgs(e)
    self.communityTokensModule.onCommunityTokenDeployStateChanged(args.communityToken.communityId, args.communityToken.chainId, args.transactionHash, args.communityToken.deployState)
  self.events.on(SIGNAL_COMMUNITY_TOKEN_DEPLOY_STATUS) do(e: Args):
    let args = CommunityTokenDeployedStatusArgs(e)
    self.communityTokensModule.onCommunityTokenDeployStateChanged(args.communityId, args.chainId, args.transactionHash, args.deployState)
  self.events.on(SIGNAL_REMOTE_DESTRUCT_STATUS) do(e: Args):
    let args = RemoteDestructArgs(e)
    self.communityTokensModule.onRemoteDestructStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_BURN_STATUS) do(e: Args):
    let args = RemoteDestructArgs(e)
    self.communityTokensModule.onBurnStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)
  self.events.on(SIGNAL_AIRDROP_STATUS) do(e: Args):
    let args = AirdropArgs(e)
    self.communityTokensModule.onAirdropStateChanged(args.communityToken.communityId, args.communityToken.name, args.communityToken.chainId, args.transactionHash, args.status)

proc deployCollectibles*(self: Controller, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, chainId: int) =
  self.communityTokensService.deployCollectibles(communityId, addressFrom, password, deploymentParams, tokenMetadata, chainId)

proc airdropCollectibles*(self: Controller, communityId: string, password: string, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string]) =
  self.communityTokensService.airdropCollectibles(communityId, password, collectiblesAndAmounts, walletAddresses)

proc computeAirdropCollectiblesFee*(self: Controller, collectiblesAndAmounts: seq[CommunityTokenAndAmount], walletAddresses: seq[string]) =
  self.communityTokensService.computeAirdropCollectiblesFee(collectiblesAndAmounts, walletAddresses)

proc selfDestructCollectibles*(self: Controller, communityId: string, password: string, walletAndAmounts: seq[WalletAndAmount], contractUniqueKey: string) =
  self.communityTokensService.selfDestructCollectibles(communityId, password, walletAndAmounts, contractUniqueKey)

proc burnCollectibles*(self: Controller, communityId: string, password: string, contractUniqueKey: string, amount: int) =
  self.communityTokensService.burnCollectibles(communityId, password, contractUniqueKey, amount)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  return self.communityTokensService.getCommunityTokens(communityId)

proc computeDeployFee*(self: Controller, chainId: int, accountAddress: string) =
  self.communityTokensService.computeDeployFee(chainId, accountAddress)

proc computeSelfDestructFee*(self: Controller, walletAndAmountList: seq[WalletAndAmount], contractUniqueKey: string) =
  self.communityTokensService.computeSelfDestructFee(walletAndAmountList, contractUniqueKey)

proc findContractByUniqueId*(self: Controller, contractUniqueKey: string): CommunityTokenDto =
  return self.communityTokensService.findContractByUniqueId(contractUniqueKey)

proc computeBurnFee*(self: Controller, contractUniqueKey: string, amount: int) =
  self.communityTokensService.computeBurnFee(contractUniqueKey, amount)

proc getNetwork*(self:Controller, chainId: int): NetworkDto =
  self.networksService.getNetwork(chainId)