import chronicles, strutils, os
import uuids
import io_interface

import ../../../global/global_singleton
import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

logScope:
  topics = "keycard-popup-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keycardService: keycard_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    connectionIds: seq[UUID]
    tmpKeycardContainsMetadata: bool
    tmpPin: string
    tmpPinMatch: bool
    tmpPassword: string
    tmpKeyUid: string
    tmpSelectedKeyPairIsProfile: bool
    tmpSelectedKeyPairName: string
    tmpSelectedKeyPairWalletPaths: seq[string]
    tmpSeedPhrase: string
    tmpSeedPhraseLength: int

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.privacyService = privacyService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.tmpKeycardContainsMetadata = false
  result.tmpPinMatch = false
  result.tmpSeedPhraseLength = 0
  result.tmpSelectedKeyPairIsProfile = false

proc disconnect*(self: Controller) =
  for id in self.connectionIds:
    self.events.disconnect(id)

proc delete*(self: Controller) =
  self.disconnect()

proc init*(self: Controller) =
  let handlerId = self.events.onWithUUID(SignalKeycardResponse) do(e: Args):
    let args = KeycardArgs(e)
    self.delegate.onKeycardResponse(args.flowType, args.flowEvent)
  self.connectionIds.add(handlerId)

proc getKeycardData*(self: Controller): string =
  return self.delegate.getKeycardData()

proc setKeycardData*(self: Controller, value: string) =
  self.delegate.setKeycardData(value)

proc containsMetadata*(self: Controller): bool =
  return self.tmpKeycardContainsMetadata

proc setContainsMetadata*(self: Controller, value: bool) =
  self.tmpKeycardContainsMetadata = value

proc setPin*(self: Controller, value: string) =
  self.tmpPin = value

proc getPin*(self: Controller): string =
  return self.tmpPin

proc setPinMatch*(self: Controller, value: bool) =
  self.tmpPinMatch = value

proc getPinMatch*(self: Controller): bool =
  return self.tmpPinMatch

proc setPassword*(self: Controller, value: string) =
  self.tmpPassword = value

proc getPassword*(self: Controller): string =
  return self.tmpPassword

proc setKeyUid*(self: Controller, value: string) =
  self.tmpKeyUid = value

proc setSelectedKeyPairIsProfile*(self: Controller, value: bool) =
  self.tmpSelectedKeyPairIsProfile = value

proc getSelectedKeyPairIsProfile*(self: Controller): bool =
  return self.tmpSelectedKeyPairIsProfile

proc setSelectedKeyPairName*(self: Controller, value: string) =
  self.tmpSelectedKeyPairName = value

proc getSelectedKeyPairName*(self: Controller): string =
  return self.tmpSelectedKeyPairName

proc setSelectedKeyPairWalletPaths*(self: Controller, paths: seq[string]) =
  self.tmpSelectedKeyPairWalletPaths = paths

proc getSelectedKeyPairWalletPaths*(self: Controller): seq[string] =
  return self.tmpSelectedKeyPairWalletPaths

proc setSeedPhrase*(self: Controller, value: string) =
  let words = value.split(" ")
  self.tmpSeedPhrase = value
  self.tmpSeedPhraseLength = words.len

proc getSeedPhrase*(self: Controller): string =
  return self.tmpSeedPhrase

proc getSeedPhraseLength*(self: Controller): int =
  return self.tmpSeedPhraseLength

proc validSeedPhrase*(self: Controller, seedPhrase: string): bool =
  let err = self.accountsService.validateMnemonic(seedPhrase)
  return err.len == 0

proc seedPhraseRefersToLoggedInUser*(self: Controller, seedPhrase: string): bool =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid == singletonInstance.userProfile.getAddress()  

proc verifyPassword*(self: Controller, password: string): bool =
  return self.accountsService.verifyPassword(password)

proc convertToKeycardAccount*(self: Controller, password: string): bool =
  singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NOT_NOW)
  return self.accountsService.convertToKeycardAccount(self.tmpKeyUid, password)

proc getLoggedInAccount*(self: Controller): AccountDto =
  return self.accountsService.getLoggedInAccount()

proc getCurrentKeycardServiceFlow*(self: Controller): keycard_service.KCSFlowType =
  return self.keycardService.getCurrentFlow()

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  return self.keycardService.getLastReceivedKeycardData()

proc setMetadataFromKeycard*(self: Controller, cardMetadata: CardMetadata) =
  self.delegate.setKeyPairStoredOnKeycard(cardMetadata)

proc cancelCurrentFlow(self: Controller) =
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one, 
  # this way we're giving to the keycard some time to cancel the current flow 
  sleep(200)

proc runGetAppInfoFlow*(self: Controller, factoryReset = false) =
  self.cancelCurrentFlow()
  self.keycardService.startGetAppInfoFlow(factoryReset)

proc runGetMetadataFlow*(self: Controller) =
  self.cancelCurrentFlow()
  self.keycardService.startGetMetadataFlow()

proc runStoreMetadataFlow*(self: Controller, cardName: string, pin: string, walletPaths: seq[string]) =
  self.cancelCurrentFlow()
  self.keycardService.startStoreMetadataFlow(cardName, pin, walletPaths)

proc runLoadAccountFlow*(self: Controller, factoryReset = false) =
  self.cancelCurrentFlow()
  self.keycardService.startLoadAccountFlow(factoryReset)

proc resumeCurrentFlowLater*(self: Controller) =
  self.keycardService.resumeCurrentFlowLater()

proc readyToDisplayPopup*(self: Controller) =
  self.events.emit(SignalSharedKeycarModuleDisplayPopup, Args())

proc terminateCurrentFlow*(self: Controller, lastStepInTheCurrentFlow: bool) =
  let data = SharedKeycarModuleFlowTerminatedArgs(lastStepInTheCurrentFlow: lastStepInTheCurrentFlow)
  self.events.emit(SignalSharedKeycarModuleFlowTerminated, data)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  if self.walletAccountService.isNil:
    debug "walletAccountService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  return self.walletAccountService.fetchAccounts()

proc getBalanceForAddress*(self: Controller, address: string): float64 =
  if self.walletAccountService.isNil:
    debug "walletAccountService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  return self.walletAccountService.fetchBalanceForAddress(address)

proc enterKeycardPin*(self: Controller, pin: string) =
  self.keycardService.enterPin(pin)

proc storePinToKeycard*(self: Controller, pin: string, puk: string) =
  self.keycardService.storePin(pin, puk)

proc storeSeedPhraseToKeycard*(self: Controller, seedPhraseLength: int, seedPhrase: string) =
  self.keycardService.storeSeedPhrase(seedPhraseLength, seedPhrase)

proc generateRandomPUK*(self: Controller): string =
  return self.keycardService.generateRandomPUK()

proc isMnemonicBackedUp*(self: Controller): bool =
  if self.privacyService.isNil:
    debug "privacyService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  return self.privacyService.isMnemonicBackedUp()

proc getMnemonic*(self: Controller): string =
  if self.privacyService.isNil:
    debug "privacyService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  return self.privacyService.getMnemonic()

proc removeMnemonic*(self: Controller) =
  if self.privacyService.isNil:
    debug "privacyService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  self.privacyService.removeMnemonic()

proc getMnemonicWordAtIndex*(self: Controller, index: int): string =
  if self.privacyService.isNil:
    debug "privacyService doesn't meant to be used from the context it's used, check the context shared popup module is used"
    return
  return self.privacyService.getMnemonicWordAtIndex(index)

proc loggedInUserUsesBiometricLogin*(self: Controller): bool =
  if(not defined(macosx)):
    return false
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE):
    return false
  return true