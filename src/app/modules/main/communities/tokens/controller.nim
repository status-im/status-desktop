import ./io_interface as community_tokens_module_interface

import ../../../../../app_service/service/community_tokens/service as community_tokens_service
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

proc newCommunityTokensController*(
    communityTokensModule: community_tokens_module_interface.AccessInterface,
    events: EventEmitter,
    communityTokensService: community_tokens_service.Service
    ): Controller =
  result = Controller()
  result.communityTokensModule = communityTokensModule
  result.events = events
  result.communityTokensService = communityTokensService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER:
      return
    self.communityTokensModule.onUserAuthenticated(args.password)

proc deployCollectibles*(self: Controller, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, tokenMetadata: CommunityTokensMetadataDto, chainId: int) =
  self.communityTokensService.deployCollectibles(communityId, addressFrom, password, deploymentParams, tokenMetadata, chainId)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_DEPLOY_COLLECTIBLES_COMMUNITY_TOKENS_MODULE_IDENTIFIER, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  return self.communityTokensService.getCommunityTokens(communityId)
