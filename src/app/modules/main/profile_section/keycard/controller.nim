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

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.delegate.onNewKeycardSet(args.keycard)

  self.events.on(SIGNAL_KEYPAIR_CHANGED) do(e: Args):
    let args = KeypairArgs(e)
    self.delegate.resolveRelatedKeycardsForKeypair(args.keypair)

  self.events.on(SIGNAL_KEYCARD_LOCKED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardLocked(args.keycard.keyUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_UNLOCKED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardUnlocked(args.keycard.keyUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_NAME_CHANGED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardNameChanged(args.keycard.keycardUid, args.keycard.keycardName)

  self.events.on(SIGNAL_KEYCARD_UID_UPDATED) do(e: Args):
    let args = KeycardActivityArgs(e)
    self.delegate.onKeycardUidUpdated(args.oldKeycardUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_ACCOUNTS_REMOVED) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardAccountsRemoved(args.keycard.keyUid, args.keycard.keycardUid, args.keycard.accountsAddresses)

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e: Args):
    let args = AccountArgs(e)
    self.delegate.onWalletAccountUpdated(args.account)

  ## TODO: will be removed in the second part of synchronization improvements
  # self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e: Args):
  #   self.delegate.rebuildKeycardsList()

  ## TODO: will be removed in the second part of synchronization improvements
  # self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e: Args):
  #   self.delegate.rebuildKeycardsList()

proc getAllKnownKeycardsGroupedByKeyUid*(self: Controller): seq[KeycardDto] =
  return self.walletAccountService.getAllKnownKeycardsGroupedByKeyUid()

proc getAllKnownKeycards*(self: Controller): seq[KeycardDto] =
  return self.walletAccountService.getAllKnownKeycards()

## TODO: will be removed in the second part of synchronization improvements
# proc getKeypairs*(self: Controller): seq[wallet_account_service.KeypairDto] =
#   return self.walletAccountService.getKeypairs()

proc getKeypairByKeyUid*(self: Controller, keyUid: string): wallet_account_service.KeypairDto =
  return self.walletAccountService.getKeypairByKeyUid(keyUid)