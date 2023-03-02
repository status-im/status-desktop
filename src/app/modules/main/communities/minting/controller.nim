import ./io_interface as minting_module_interface

import ../../../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../../core/signals/types
import ../../../../core/eventemitter
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module


const UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER* = "MintingModule-MintCollectibles"

type
  Controller* = ref object of RootObj
    mintingModule: minting_module_interface.AccessInterface
    events: EventEmitter
    communityTokensService: community_tokens_service.Service

proc newMintingController*(
    mintingModule: minting_module_interface.AccessInterface,
    events: EventEmitter,
    communityTokensService: community_tokens_service.Service
    ): Controller =
  result = Controller()
  result.mintingModule = mintingModule
  result.events = events
  result.communityTokensService = communityTokensService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER:
      return
    self.mintingModule.onUserAuthenticated(args.password)

proc mintCollectibles*(self: Controller, communityId: string, addressFrom: string, password: string, deploymentParams: DeploymentParameters, chainId: int) =
  self.communityTokensService.mintCollectibles(communityId, addressFrom, password, deploymentParams, chainId)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getCommunityTokens*(self: Controller, communityId: string): seq[CommunityTokenDto] =
  return self.communityTokensService.getCommunityTokens(communityId)
