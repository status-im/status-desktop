import chronicles, strutils, os
import uuids
import io_interface

import ../../../global/global_singleton
import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/keychain/service as keychain_service

logScope:
  topics = "keycard-popup-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    uniqueIdentifier: string
    events: EventEmitter
    keycardService: keycard_service.Service
    settingsService: settings_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keychainService: keychain_service.Service
    connectionIds: seq[UUID]
    keychainConnectionIds: seq[UUID]
    connectionKeycardResponse: UUID
    tmpKeycardContainsMetadata: bool
    tmpCardMetadata: CardMetadata
    tmpKeycardUidForProcessing: string
    tmpPin: string
    tmpPinMatch: bool
    tmpPuk: string
    tmpPukMatch: bool
    tmpValidPuk: bool
    tmpPassword: string
    tmpKeycardName: string
    tmpPairingCode: string
    tmpSelectedKeyPairIsProfile: bool
    tmpSelectedKeyPairDto: KeyPairDto
    tmpSelectedKeyPairWalletPaths: seq[string]
    tmpSeedPhrase: string
    tmpSeedPhraseLength: int
    tmpKeyUidWhichIsBeingAuthenticating: string
    tmpKeyUidWhichIsBeingUnlocking: string
    tmpUsePinFromBiometrics: bool
    tmpOfferToStoreUpdatedPinToKeychain: bool
    tmpKeycardUid: string

proc newController*(delegate: io_interface.AccessInterface,
  uniqueIdentifier: string,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  keychainService: keychain_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.uniqueIdentifier = uniqueIdentifier
  result.events = events
  result.keycardService = keycardService
  result.settingsService = settingsService
  result.privacyService = privacyService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.keychainService = keychainService
  result.tmpKeycardContainsMetadata = false
  result.tmpPinMatch = false
  result.tmpValidPuk = false
  result.tmpSeedPhraseLength = 0
  result.tmpSelectedKeyPairIsProfile = false
  result.tmpUsePinFromBiometrics = false

proc serviceApplicable[T](service: T): bool =
  if not service.isNil:
    return true
  var serviceName = ""
  when (service is wallet_account_service.Service):
    serviceName = "WalletAccountService"
  when (service is privacy_service.Service):
    serviceName = "PrivacyService"
  when (service is settings_service.Service):
    serviceName = "SettingsService"
  debug "service doesn't meant to be used from the context it's used, check the context shared popup module is used", service=serviceName

proc disconnectKeycardReponseSignal(self: Controller) =
  self.events.disconnect(self.connectionKeycardResponse)

proc connectKeycardReponseSignal(self: Controller) =
  self.connectionKeycardResponse = self.events.onWithUUID(SIGNAL_KEYCARD_RESPONSE) do(e: Args):
    let args = KeycardArgs(e)
    self.delegate.onKeycardResponse(args.flowType, args.flowEvent)

proc connectKeychainSignals*(self: Controller) =
  var handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.keychainObtainedDataSuccess(args.data)
  self.keychainConnectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.keychainObtainedDataFailure(args.errDescription, args.errType)
  self.keychainConnectionIds.add(handlerId)

proc disconnectKeychainSignals(self: Controller) =
  for id in self.keychainConnectionIds:
    self.events.disconnect(id)

proc disconnectAll*(self: Controller) =
  self.disconnectKeycardReponseSignal()
  self.disconnectKeychainSignals()
  for id in self.connectionIds:
    self.events.disconnect(id)

proc delete*(self: Controller) =
  self.disconnectAll()

proc init*(self: Controller) =
  self.connectKeycardReponseSignal()

  let handlerId = self.events.onWithUUID(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != self.uniqueIdentifier:
      return
    self.connectKeycardReponseSignal()
    self.delegate.onUserAuthenticated(args.password)
  self.connectionIds.add(handlerId)

proc getKeycardData*(self: Controller): string =
  return self.delegate.getKeycardData()

proc setKeycardData*(self: Controller, value: string) =
  self.delegate.setKeycardData(value)

proc containsMetadata*(self: Controller): bool =
  return self.tmpKeycardContainsMetadata

proc setContainsMetadata*(self: Controller, value: bool) =
  self.tmpKeycardContainsMetadata = value

proc setUidOfAKeycardWhichNeedToBeProcessed*(self: Controller, value: string) =
  self.tmpKeycardUidForProcessing = value

proc getUidOfAKeycardWhichNeedToBeProcessed*(self: Controller): string =
  return self.tmpKeycardUidForProcessing

proc setPin*(self: Controller, value: string) =
  self.tmpPin = value

proc getPin*(self: Controller): string =
  return self.tmpPin

proc setPuk*(self: Controller, value: string) =
  self.tmpPuk = value

proc getPuk*(self: Controller): string =
  return self.tmpPuk

proc setPukValid*(self: Controller, value: bool) =
  self.tmpValidPuk = value

proc getValidPuk*(self: Controller): bool =
  return self.tmpValidPuk

proc setPukMatch*(self: Controller, value: bool) =
  self.tmpPukMatch = value

proc getPukMatch*(self: Controller): bool =
  return self.tmpPukMatch

proc setUsePinFromBiometrics*(self: Controller, value: bool) =
  self.tmpUsePinFromBiometrics = value

proc usePinFromBiometrics*(self: Controller): bool =
  return self.tmpUsePinFromBiometrics

proc setPinMatch*(self: Controller, value: bool) =
  self.tmpPinMatch = value

proc getPinMatch*(self: Controller): bool =
  return self.tmpPinMatch

proc setOfferToStoreUpdatedPinToKeychain*(self: Controller, value: bool) =
  self.tmpOfferToStoreUpdatedPinToKeychain = value

proc offerToStoreUpdatedPinToKeychain*(self: Controller): bool =
  return self.tmpOfferToStoreUpdatedPinToKeychain

proc setPassword*(self: Controller, value: string) =
  self.tmpPassword = value

proc getPassword*(self: Controller): string =
  return self.tmpPassword

proc setKeycarName*(self: Controller, value: string) =
  self.tmpKeycardName = value

proc getKeycarName*(self: Controller): string =
  return self.tmpKeycardName

proc setPairingCode*(self: Controller, value: string) =
  self.tmpPairingCode = value

proc getPairingCode*(self: Controller): string =
  return self.tmpPairingCode

proc getKeyUidWhichIsBeingAuthenticating*(self: Controller): string =
  self.tmpKeyUidWhichIsBeingAuthenticating

proc getKeyUidWhichIsBeingUnlocking*(self: Controller): string =
  self.tmpKeyUidWhichIsBeingUnlocking

proc setKeyUidWhichIsBeingUnlocking*(self: Controller, keyUid: string) =
  self.tmpKeyUidWhichIsBeingUnlocking = keyUid

proc setSelectedKeyPairIsProfile*(self: Controller, value: bool) =
  self.tmpSelectedKeyPairIsProfile = value

proc getSelectedKeyPairIsProfile*(self: Controller): bool =
  return self.tmpSelectedKeyPairIsProfile

proc setSelectedKeyPairDto*(self: Controller, keyPairDto: KeyPairDto) =
  self.tmpSelectedKeyPairDto = keyPairDto

proc getSelectedKeyPairDto*(self: Controller): KeyPairDto =
  return self.tmpSelectedKeyPairDto

proc setKeycardUidTheSelectedKeypairIsMigratedTo*(self: Controller, value: string) =
  self.tmpSelectedKeyPairDto.keycardUid = value

proc setKeycardUid*(self: Controller, value: string) =
  self.tmpKeycardUid = value

proc getKeycardUid*(self: Controller): string =
  return self.tmpKeycardUid

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

proc getKeyUidForSeedPhrase*(self: Controller, seedPhrase: string): string =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid

proc seedPhraseRefersToSelectedKeyPair*(self: Controller, seedPhrase: string): bool =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid == self.tmpSelectedKeyPairDto.keyUid

proc verifyPassword*(self: Controller, password: string): bool =
  return self.accountsService.verifyPassword(password)

proc convertSelectedKeyPairToKeycardAccount*(self: Controller, password: string): bool =
  singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NOT_NOW)
  return self.accountsService.convertToKeycardAccount(self.tmpSelectedKeyPairDto.keyUid, password)

proc getLoggedInAccount*(self: Controller): AccountDto =
  return self.accountsService.getLoggedInAccount()

proc getCurrentKeycardServiceFlow*(self: Controller): keycard_service.KCSFlowType =
  return self.keycardService.getCurrentFlow()

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  return self.keycardService.getLastReceivedKeycardData()

proc getMetadataFromKeycard*(self: Controller): CardMetadata =
  return self.tmpCardMetadata

proc setMetadataFromKeycard*(self: Controller, cardMetadata: CardMetadata, updateKeyPair = false) =
  self.tmpCardMetadata = cardMetadata
  if updateKeyPair:
    self.delegate.setKeyPairStoredOnKeycard(cardMetadata)

proc setNamePropForKeyPairStoredOnKeycard*(self: Controller, name: string) =
  self.delegate.setNamePropForKeyPairStoredOnKeycard(name)

proc runSharedModuleFlow*(self: Controller, flowToRun: FlowType) =
  self.delegate.runFlow(flowToRun)

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one, 
  # this way we're giving to the keycard some time to cancel the current flow 
  sleep(200)

proc runGetAppInfoFlow*(self: Controller, factoryReset = false) =
  self.cancelCurrentFlow()
  self.keycardService.startGetAppInfoFlow(factoryReset)

proc runGetMetadataFlow*(self: Controller, resolveAddress = false) =
  self.cancelCurrentFlow()
  self.keycardService.startGetMetadataFlow(resolveAddress)

proc runChangePinFlow*(self: Controller) =
  self.cancelCurrentFlow()
  self.keycardService.startChangePinFlow()

proc runChangePukFlow*(self: Controller) =
  self.cancelCurrentFlow()
  self.keycardService.startChangePukFlow()

proc runChangePairingFlow*(self: Controller) =
  self.cancelCurrentFlow()
  self.keycardService.startChangePairingFlow()

proc runStoreMetadataFlow*(self: Controller, cardName: string, pin: string, walletPaths: seq[string]) =
  self.cancelCurrentFlow()
  self.keycardService.startStoreMetadataFlow(cardName, pin, walletPaths)

proc runLoadAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", puk = "", factoryReset = false) =
  self.cancelCurrentFlow()
  self.keycardService.startLoadAccountFlow(seedPhraseLength, seedPhrase, puk, factoryReset)

proc runSignFlow*(self: Controller, keyUid = "", bip44Path = "", txHash = "") =
  ## For signing a transaction  we need to provide a key uid of a keypair that an account we want to sign a transaction 
  ## for belongs to. If we're just doing an authentication for a logged in user, then default key uid is always the key 
  ## uid of the logged in user.
  self.tmpKeyUidWhichIsBeingAuthenticating = keyUid
  if self.tmpKeyUidWhichIsBeingAuthenticating.len == 0:
    self.tmpKeyUidWhichIsBeingAuthenticating = singletonInstance.userProfile.getKeyUid()
  self.cancelCurrentFlow()
  self.keycardService.startSignFlow(bip44Path, txHash)

proc resumeCurrentFlowLater*(self: Controller) =
  self.keycardService.resumeCurrentFlowLater()

proc readyToDisplayPopup*(self: Controller) =
  let data = SharedKeycarModuleBaseArgs(uniqueIdentifier: self.uniqueIdentifier)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP, data)

proc terminateCurrentFlow*(self: Controller, lastStepInTheCurrentFlow: bool) =
  self.cancelCurrentFlow()
  let (_, flowEvent) = self.getLastReceivedKeycardData()
  var data = SharedKeycarModuleFlowTerminatedArgs(uniqueIdentifier: self.uniqueIdentifier,
    lastStepInTheCurrentFlow: lastStepInTheCurrentFlow)
  if lastStepInTheCurrentFlow:
    data.password = self.tmpPassword
    data.keyUid = flowEvent.keyUid
    data.txR = flowEvent.txSignature.r
    data.txS = flowEvent.txSignature.s
    data.txV = flowEvent.txSignature.v
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED, data)

proc authenticateUser*(self: Controller) =
  self.disconnectKeycardReponseSignal()
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: self.uniqueIdentifier)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.fetchAccounts()

proc getBalanceForAddress*(self: Controller, address: string): float64 =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.fetchBalanceForAddress(address)

proc addMigratedKeyPair*(self: Controller, keyPair: KeyPairDto): bool =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.addMigratedKeyPair(keyPair)

proc getAllMigratedKeyPairs*(self: Controller): seq[KeyPairDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getAllMigratedKeyPairs()

proc getMigratedKeyPairByKeyUid*(self: Controller, keyUid: string): seq[KeyPairDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getMigratedKeyPairByKeyUid(keyUid)

proc setCurrentKeycardStateToLocked*(self: Controller, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  if not self.walletAccountService.setKeycardLocked(keycardUid):
    info "updating keycard locked state failed", keycardUid=keycardUid

proc setCurrentKeycardStateToUnlocked*(self: Controller, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  if not self.walletAccountService.setKeycardUnlocked(keycardUid):
    info "updating keycard unlocked state failed", keycardUid=keycardUid

proc setKeycardName*(self: Controller, keycardUid: string, keycardName: string): bool =
  if not serviceApplicable(self.walletAccountService):
    return false
  if not self.walletAccountService.setKeycardName(keycardUid, keycardName):
    info "updating keycard name failed", keycardUid=keycardUid
    return false
  return true

proc updateKeycardUid*(self: Controller, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  self.setCurrentKeycardStateToUnlocked(self.tmpKeycardUid)
  if self.tmpKeycardUid != keycardUid:
    if not self.walletAccountService.updateKeycardUid(self.tmpKeycardUid, keycardUid):
      self.tmpKeycardUid = keycardUid
      info "update keycard uid failed", oldKeycardUid=self.tmpKeycardUid, newKeycardUid=keycardUid

proc getSigningPhrase*(self: Controller): string =
  if not serviceApplicable(self.settingsService):
    return
  return self.settingsService.getSigningPhrase()

proc enterKeycardPin*(self: Controller, pin: string) =
  self.keycardService.enterPin(pin)

proc enterKeycardPuk*(self: Controller, puk: string) =
  self.keycardService.enterPuk(puk)

proc storePinToKeycard*(self: Controller, pin: string, puk: string) =
  self.keycardService.storePin(pin, puk)

proc storePukToKeycard*(self: Controller, puk: string) =
  self.keycardService.storePuk(puk)

proc storePairingCodeToKeycard*(self: Controller, pairingCode: string) =
  self.keycardService.storePairingCode(pairingCode)

proc storeSeedPhraseToKeycard*(self: Controller, seedPhraseLength: int, seedPhrase: string) =
  self.keycardService.storeSeedPhrase(seedPhraseLength, seedPhrase)

proc generateRandomPUK*(self: Controller): string =
  return self.keycardService.generateRandomPUK()

proc isMnemonicBackedUp*(self: Controller): bool =
  if not serviceApplicable(self.privacyService):
    return
  return self.privacyService.isMnemonicBackedUp()

proc getMnemonic*(self: Controller): string =
  if not serviceApplicable(self.privacyService):
    return
  return self.privacyService.getMnemonic()

proc removeMnemonic*(self: Controller) =
  if not serviceApplicable(self.privacyService):
    return
  self.privacyService.removeMnemonic()

proc getMnemonicWordAtIndex*(self: Controller, index: int): string =
  if not serviceApplicable(self.privacyService):
    return
  return self.privacyService.getMnemonicWordAtIndex(index)

proc tryToObtainDataFromKeychain*(self: Controller) =
  if(not singletonInstance.userProfile.getUsingBiometricLogin()):
    return
  let loggedInAccount = self.getLoggedInAccount()
  self.keychainService.tryToObtainData(loggedInAccount.name)

proc tryToStoreDataToKeychain*(self: Controller, password: string) =
  let loggedInAccount = self.getLoggedInAccount()
  self.keychainService.storeData(loggedInAccount.name, password)