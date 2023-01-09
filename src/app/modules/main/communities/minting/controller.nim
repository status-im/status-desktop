import ./io_interface as minting_module_interface

import ../../../../../app_service/service/community_tokens/service as tokens_service
import ../../../../../app_service/service/community_tokens/dto/deployment_parameters
import ../../../../core/signals/types
import ../../../../core/eventemitter
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module


const UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER* = "MintingModule-MintCollectibles"

type
  Controller* = ref object of RootObj
    mintingModule: minting_module_interface.AccessInterface
    events: EventEmitter
    tokensService: tokens_service.Service

proc newMintingController*(
    mintingModule: minting_module_interface.AccessInterface,
    events: EventEmitter,
    tokensService: tokens_service.Service
    ): Controller =
  result = Controller()
  result.mintingModule = mintingModule
  result.events = events
  result.tokensService = tokensService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER:
      return
    self.mintingModule.onUserAuthenticated(args.password)

proc mintCollectibles*(self: Controller, addressFrom: string, password: string, deploymentParams: DeploymentParameters) =
  self.tokensService.mintCollectibles(addressFrom, password, deploymentParams)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_MINT_COLLECTIBLES_MINTING_MODULE_IDENTIFIER, keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)