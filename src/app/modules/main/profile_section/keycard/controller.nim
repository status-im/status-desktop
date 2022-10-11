import chronicles

import io_interface

import ../../../../core/eventemitter

import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module
import ../../../../../app_service/service/contacts/service as contact_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

logScope:
  topics = "profile-section-keycard-module-controller"

const UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER* = "Settings-KeycardModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  
proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED) do(e: Args):
    let args = SharedKeycarModuleFlowTerminatedArgs(e)
    if args.uniqueIdentifier != UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER:
      return
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP) do(e: Args):
    let args = SharedKeycarModuleBaseArgs(e)
    if args.uniqueIdentifier != UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER:
      return
    self.delegate.onDisplayKeycardSharedModuleFlow()

  self.events.on(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED) do(e: Args):
    self.delegate.onLoggedInUserImageChanged()

  self.events.on(SIGNAL_KEYCARD_LOCKED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardLocked(args.keycardUid)

  self.events.on(SIGNAL_KEYCARD_UNLOCKED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardUnlocked(args.keycardUid)

  self.events.on(SIGNAL_KEYCARD_UID_UPDATED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardUidUpdated(args.keycardUid, args.keycardNewUid)

proc getAllMigratedKeyPairs*(self: Controller): seq[KeyPairDto] =
  return self.walletAccountService.getAllMigratedKeyPairs()

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.fetchAccounts()