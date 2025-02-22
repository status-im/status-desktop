import chronicles

import io_interface

import app/core/eventemitter

import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module
import app_service/service/contacts/service as contact_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/settings/service as settings_service

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
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow, args.continueWithNextFlow,
      args.forceFlow, args.continueWithKeyUid, args.returnToFlow)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP) do(e: Args):
    let args = SharedKeycarModuleBaseArgs(e)
    if args.uniqueIdentifier != UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER:
      return
    self.delegate.onDisplayKeycardSharedModuleFlow()

  self.events.on(SIGNAL_KEYPAIR_SYNCED) do(e: Args):
    let args = KeypairArgs(e)
    self.delegate.onKeypairSynced(args.keypair)

  self.events.on(SIGNAL_DISPLAY_NAME_UPDATED) do(e: Args):
    self.delegate.onLoggedInUserNameChanged()

  self.events.on(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED) do(e: Args):
    self.delegate.onLoggedInUserImageChanged()

  self.events.on(SIGNAL_KEYCARD_REBUILD) do(e: Args):
    self.delegate.rebuildAllKeycards()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardChange(args.keycard)

  self.events.on(SIGNAL_ALL_KEYCARDS_DELETED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardChange(args.keycard)

  self.events.on(SIGNAL_KEYCARD_LOCKED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardLocked(args.keycard.keyUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_UNLOCKED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardUnlocked(args.keycard.keyUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_NAME_CHANGED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardNameChanged(args.keycard.keycardUid, args.keycard.keycardName)

  self.events.on(SIGNAL_KEYCARD_UID_UPDATED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardUidUpdated(args.oldKeycardUid, args.keycard.keycardUid)

  self.events.on(SIGNAL_KEYCARD_ACCOUNTS_REMOVED) do(e: Args):
    let args = KeycardArgs(e)
    if not args.success:
      return
    self.delegate.onKeycardChange(args.keycard)

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e: Args):
    let args = AccountArgs(e)
    self.delegate.onWalletAccountChange(args.account)

  self.events.on(SIGNAL_WALLET_ACCOUNT_POSITION_UPDATED) do(e: Args):
    self.delegate.rebuildAllKeycards()

  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e: Args):
    let args = AccountArgs(e)
    self.delegate.onWalletAccountChange(args.account)

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e: Args):
    let args = AccountArgs(e)
    self.delegate.onWalletAccountChange(args.account)

proc getKeycardsWithSameKeyUid*(self: Controller, keyUid: string): seq[KeycardDto] =
  return self.walletAccountService.getKeycardsWithSameKeyUid(keyUid)

proc getKeypairs*(self: Controller): seq[wallet_account_service.KeypairDto] =
  return self.walletAccountService.getKeypairs()

proc getKeypairByKeyUid*(self: Controller, keyUid: string): wallet_account_service.KeypairDto =
  return self.walletAccountService.getKeypairByKeyUid(keyUid)

proc remainingKeypairCapacity*(self: Controller): int =
  return self.walletAccountService.remainingKeypairCapacity()

proc remainingAccountCapacity*(self: Controller): int =
  return self.walletAccountService.remainingAccountCapacity()