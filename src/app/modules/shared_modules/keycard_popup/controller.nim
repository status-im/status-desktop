import chronicles, tables, strutils, os, sequtils, sugar
import uuids
import io_interface

import ../../../global/app_sections_config as conf
import ../../../global/app_signals
import ../../../global/global_singleton
import ../../../core/signals/types
import ../../../core/eventemitter
import ../../startup/io_interface as startup_io
import ../../../../app_service/common/utils
import ../../../../app_service/common/account_constants
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/privacy/service as privacy_service
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/keychain/service as keychain_service
import ../../../../app_service/service/currency/dto

import ../../shared_models/[keypair_item]

logScope:
  topics = "keycard-popup-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    uniqueIdentifier: string
    events: EventEmitter
    keycardService: keycard_service.Service
    settingsService: settings_service.Service
    networkService: network_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keychainService: keychain_service.Service
    connectionIds: seq[UUID]
    keychainConnectionIds: seq[UUID]
    connectionKeycardResponse: UUID
    connectionKeycardSyncTerminatedSignal: UUID
    tmpKeycardContainsMetadata: bool
    tmpCardMetadata: CardMetadata
    tmpPin: string
    tmpPinMatch: bool
    tmpPuk: string
    tmpPukMatch: bool
    tmpValidPuk: bool
    tmpPassword: string
    tmpPairingCode: string
    tmpSelectedKeyPairIsProfile: bool
    tmpSelectedKeycardDto: KeycardDto
    tmpSelectedKeyPairWalletPaths: seq[string]
    tmpSeedPhrase: string
    tmpSeedPhraseLength: int
    tmpKeyUidWhichIsBeingAuthenticating: string
    tmpKeyUidWhichIsBeingSyncing: string
    tmpUsePinFromBiometrics: bool
    tmpOfferToStoreUpdatedPinToKeychain: bool
    tmpKeycardUid: string
    tmpAddingMigratedKeypairSuccess: bool
    tmpConvertingProfileSuccess: bool
    tmpKeycardImportCardMetadata: CardMetadata
    tmpKeycardCopyCardMetadata: CardMetadata
    tmpKeycardCopyPin: string
    tmpKeycardCopyDestinationKeycardUid: string
    tmpKeycardSyncingInProgress: bool
    tmpFlowData: SharedKeycarModuleFlowTerminatedArgs
    tmpRequestedPathsAlongWithAuthentication: seq[string]
    tmpUnlockUsingSeedPhrase: bool # true - sp, false - puk

proc newController*(delegate: io_interface.AccessInterface,
  uniqueIdentifier: string,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  settingsService: settings_service.Service,
  networkService: network_service.Service,
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
  result.networkService = networkService
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
  result.tmpAddingMigratedKeypairSuccess = false
  result.tmpConvertingProfileSuccess = false
  result.tmpKeycardSyncingInProgress = false

## Forward declaration:
proc finishFlowTermination(self: Controller)

proc serviceApplicable[T](service: T): bool =
  if not service.isNil:
    return true
  when (service is keycard_service.Service):
    error "KeycardService is mandatory for using shared keycard popup module"
    return
  var serviceName = ""
  when (service is wallet_account_service.Service):
    serviceName = "WalletAccountService"
  when (service is privacy_service.Service):
    serviceName = "PrivacyService"
  when (service is settings_service.Service):
    serviceName = "SettingsService"
  when (service is network_service.Service):
    serviceName = "NetworkService"
  when (service is accounts_service.Service):
    serviceName = "AccountsService"
  when (service is keychain_service.Service):
    serviceName = "KeychainService"
  debug "service is not set, check the context shared keycard popup module is used", service=serviceName

proc disconnectKeycardReponseSignal(self: Controller) =
  self.events.disconnect(self.connectionKeycardResponse)

proc connectKeycardReponseSignal(self: Controller) =
  self.connectionKeycardResponse = self.events.onWithUUID(SIGNAL_KEYCARD_RESPONSE) do(e: Args):
    let args = KeycardLibArgs(e)
    self.delegate.onKeycardResponse(args.flowType, args.flowEvent)

proc disconnectKeycardSyncSignal(self: Controller) =
  self.events.disconnect(self.connectionKeycardSyncTerminatedSignal)

proc connectKeycardSyncSignal(self: Controller) =
  self.connectionKeycardSyncTerminatedSignal = self.events.onWithUUID(SIGNAL_SHARED_KEYCARD_MODULE_KEYCARD_SYNC_TERMINATED) do(e: Args):
    self.disconnectKeycardSyncSignal()
    self.connectKeycardReponseSignal()
    self.finishFlowTermination()

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

proc init*(self: Controller, fullConnect = true) =
  self.connectKeycardReponseSignal()

  var handlerId = self.events.onWithUUID(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != self.uniqueIdentifier:
      return
    self.connectKeycardReponseSignal()
    self.delegate.onUserAuthenticated(args.password, args.pin)
  self.connectionIds.add(handlerId)

  if fullConnect:
    handlerId = self.events.onWithUUID(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
      let args = KeycardArgs(e)
      self.tmpAddingMigratedKeypairSuccess = args.success
      self.delegate.onSecondaryActionClicked()
    self.connectionIds.add(handlerId)

    handlerId = self.events.onWithUUID(SIGNAL_CONVERTING_PROFILE_KEYPAIR) do(e: Args):
      let args = ResultArgs(e)
      self.tmpConvertingProfileSuccess = args.success
      self.delegate.onSecondaryActionClicked()
    self.connectionIds.add(handlerId)

    handlerId = self.events.onWithUUID(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
      let arg = TokensPerAccountArgs(e)
      self.delegate.onTokensRebuilt(arg.accountsTokens)
    self.connectionIds.add(handlerId)

proc switchToWalletSection*(self: Controller) =
  let data = ActiveSectionChatArgs(sectionId: conf.WALLET_SECTION_ID)
  self.events.emit(SIGNAL_MAKE_SECTION_CHAT_ACTIVE, data)

proc getKeycardData*(self: Controller): string =
  return self.delegate.getKeycardData()

proc setKeycardData*(self: Controller, value: string) =
  self.delegate.setKeycardData(value)

proc setRemainingAttempts*(self: Controller, value: int) =
  self.delegate.setRemainingAttempts(value)

proc containsMetadata*(self: Controller): bool =
  return self.tmpKeycardContainsMetadata

proc setContainsMetadata*(self: Controller, value: bool) =
  self.tmpKeycardContainsMetadata = value

proc setKeyPairForProcessing*(self: Controller, item: KeyPairItem) =
  self.delegate.setKeyPairForProcessing(item)

proc prepareKeyPairForProcessing*(self: Controller, keyUid: string) =
  self.delegate.prepareKeyPairForProcessing(keyUid)

proc getKeyPairForProcessing*(self: Controller): KeyPairItem =
  return self.delegate.getKeyPairForProcessing()

proc getKeyPairHelper*(self: Controller): KeyPairItem =
  return self.delegate.getKeyPairHelper()

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

proc setPairingCode*(self: Controller, value: string) =
  self.tmpPairingCode = value

proc getPairingCode*(self: Controller): string =
  return self.tmpPairingCode

proc getKeyUidWhichIsBeingAuthenticating*(self: Controller): string =
  return self.tmpKeyUidWhichIsBeingAuthenticating

proc getKeyUidWhichIsBeingSyncing*(self: Controller): string =
  return self.tmpKeyUidWhichIsBeingSyncing

proc setKeyUidWhichIsBeingSyncing*(self: Controller, value: string) =
  self.tmpKeyUidWhichIsBeingSyncing = value

proc keycardSyncingInProgress*(self: Controller): bool =
  return self.tmpKeycardSyncingInProgress

proc setKeycardSyncingInProgress*(self: Controller, value: bool) =
  self.tmpKeycardSyncingInProgress = value

proc unlockUsingSeedPhrase*(self: Controller): bool =
  return self.tmpUnlockUsingSeedPhrase

proc setUnlockUsingSeedPhrase*(self: Controller, value: bool) =
  self.tmpUnlockUsingSeedPhrase = value

proc setSelectedKeyPair*(self: Controller, isProfile: bool, paths: seq[string], keycardDto: KeycardDto) =
  if paths.len != keycardDto.accountsAddresses.len:
    error "selected keypair has different number of paths and addresses"
    return
  self.tmpSelectedKeyPairIsProfile = isProfile
  self.tmpSelectedKeyPairWalletPaths = paths
  self.tmpSelectedKeycardDto = keycardDto

proc getSelectedKeyPairIsProfile*(self: Controller): bool =
  return self.tmpSelectedKeyPairIsProfile

proc getSelectedKeyPairDto*(self: Controller): KeycardDto =
  return self.tmpSelectedKeycardDto

proc getSelectedKeyPairWalletPaths*(self: Controller): seq[string] =
  return self.tmpSelectedKeyPairWalletPaths

proc setSelectedKeypairAsKeyPairForProcessing*(self: Controller) =
  var cardMetadata = CardMetadata(name: self.tmpSelectedKeycardDto.keycardName)
  for i in 0 ..< self.tmpSelectedKeyPairWalletPaths.len:
    cardMetadata.walletAccounts.add(WalletAccount(path: self.tmpSelectedKeyPairWalletPaths[i],
      address: self.tmpSelectedKeycardDto.accountsAddresses[i]))
  self.delegate.updateKeyPairForProcessing(cardMetadata)

proc setKeycardUidTheSelectedKeypairIsMigratedTo*(self: Controller, value: string) =
  self.tmpSelectedKeycardDto.keycardUid = value

proc setKeycardUid*(self: Controller, value: string) =
  self.tmpKeycardUid = value

proc getKeycardUid*(self: Controller): string =
  return self.tmpKeycardUid

proc setDestinationKeycardUid*(self: Controller, value: string) =
  self.tmpKeycardCopyDestinationKeycardUid = value

proc getDestinationKeycardUid*(self: Controller): string =
  return self.tmpKeycardCopyDestinationKeycardUid

proc setSeedPhrase*(self: Controller, value: string) =
  let words = value.split(" ")
  self.tmpSeedPhrase = value
  self.tmpSeedPhraseLength = words.len

proc getSeedPhrase*(self: Controller): string =
  return self.tmpSeedPhrase

proc getSeedPhraseLength*(self: Controller): int =
  return self.tmpSeedPhraseLength

proc validSeedPhrase*(self: Controller, seedPhrase: string): bool =
  if not serviceApplicable(self.accountsService):
    return
  let err = self.accountsService.validateMnemonic(seedPhrase)
  return err.len == 0

proc getKeyUidForSeedPhrase*(self: Controller, seedPhrase: string): string =
  if not serviceApplicable(self.accountsService):
    return
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid

proc generateAccountsFromSeedPhrase*(self: Controller, seedPhrase: string, paths: seq[string]): GeneratedAccountDto =
  if not serviceApplicable(self.accountsService):
    return
  return self.accountsService.createAccountFromMnemonic(seedPhrase, paths)

proc buildSeedPhrasesFromIndexes*(self: Controller, seedPhraseIndexes: seq[int]) =
  if seedPhraseIndexes.len == 0:
    let err = "cannot generate seed phrase from empty array"
    error "keycard error: ", err
    return
  let sp = self.keycardService.buildSeedPhrasesFromIndexes(seedPhraseIndexes)
  self.setSeedPhrase(sp.join(" "))

proc verifyPassword*(self: Controller, password: string): bool =
  if not serviceApplicable(self.accountsService):
    return
  return self.accountsService.verifyPassword(password)

proc convertSelectedKeyPairToKeycardAccount*(self: Controller, keycardUid: string, password: string) =
  if not serviceApplicable(self.accountsService):
    return
  let acc = self.accountsService.createAccountFromMnemonic(self.getSeedPhrase(), includeEncryption = true)
  singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NOT_NOW)
  self.accountsService.convertToKeycardAccount(keycardUid, currentPassword = password,
    newPassword = acc.derivedAccounts.encryption.publicKey)

proc getConvertingProfileSuccess*(self: Controller): bool =
  return self.tmpConvertingProfileSuccess

proc getLoggedInAccount*(self: Controller): AccountDto =
  if not serviceApplicable(self.accountsService):
    return
  return self.accountsService.getLoggedInAccount()

proc getCurrentKeycardServiceFlow*(self: Controller): keycard_service.KCSFlowType =
  if not serviceApplicable(self.keycardService):
    return
  return self.keycardService.getCurrentFlow()

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  if not serviceApplicable(self.keycardService):
    return
  return self.keycardService.getLastReceivedKeycardData()

proc cleanReceivedKeycardData*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.cleanReceivedKeycardData()

proc getMetadataFromKeycard*(self: Controller): CardMetadata =
  return self.tmpCardMetadata

proc setMetadataFromKeycard*(self: Controller, cardMetadata: CardMetadata) =
  self.tmpCardMetadata = cardMetadata
  self.delegate.updateKeyPairForProcessing(cardMetadata)

proc getMetadataForKeycardCopy*(self: Controller): CardMetadata =
  return self.tmpKeycardCopyCardMetadata

proc setMetadataForKeycardCopy*(self: Controller, cardMetadata: CardMetadata) =
  self.tmpKeycardCopyCardMetadata = cardMetadata
  self.setMetadataFromKeycard(cardMetadata)

proc getMetadataForKeycardImport*(self: Controller): CardMetadata =
  return self.tmpKeycardImportCardMetadata

proc setMetadataForKeycardImport*(self: Controller, cardMetadata: CardMetadata) =
  self.tmpKeycardImportCardMetadata = cardMetadata
  self.delegate.updateKeyPairHelper(cardMetadata)

proc setPinForKeycardCopy*(self: Controller, value: string) =
  self.tmpKeycardCopyPin = value

proc getPinForKeycardCopy*(self: Controller): string =
  return self.tmpKeycardCopyPin

proc runSharedModuleFlow*(self: Controller, flowToRun: FlowType, keyUid = "") =
  self.delegate.runFlow(flowToRun, keyUid)

proc cancelCurrentFlow*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one,
  # this way we're giving to the keycard some time to cancel the current flow
  sleep(200)

proc runGetAppInfoFlow*(self: Controller, factoryReset = false) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startGetAppInfoFlow(factoryReset)

proc runGetMetadataFlow*(self: Controller, resolveAddress = false, exportMasterAddr = false, pin = "") =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startGetMetadataFlow(resolveAddress, exportMasterAddr, pin)

proc runChangePinFlow*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startChangePinFlow()

proc runChangePukFlow*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startChangePukFlow()

proc runChangePairingFlow*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startChangePairingFlow()

proc runStoreMetadataFlow*(self: Controller, cardName: string, pin: string, walletPaths: seq[string]) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startStoreMetadataFlow(cardName, pin, walletPaths)

proc runDeriveAccountFlow*(self: Controller, bip44Path: string, pin: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startExportPublicFlow(bip44Path, exportMasterAddr=true, exportPrivateAddr=false, pin)

proc runDeriveAccountFlow*(self: Controller, bip44Paths: seq[string], pin: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startExportPublicFlow(bip44Paths, exportMasterAddr=true, exportPrivateAddr=false, pin)

proc runAuthenticationFlow*(self: Controller, keyUid = "", bip44Paths: seq[string] = @[]) =
  ## For signing a transaction  we need to provide a key uid of a keypair that an account we want to sign a transaction
  ## for belongs to. If we're just doing an authentication for a logged in user, then default key uid is always the key
  ## uid of the logged in user.
  if not serviceApplicable(self.keycardService):
    return
  self.tmpKeyUidWhichIsBeingAuthenticating = keyUid
  if self.tmpKeyUidWhichIsBeingAuthenticating.len == 0:
    self.tmpKeyUidWhichIsBeingAuthenticating = singletonInstance.userProfile.getKeyUid()
  self.cancelCurrentFlow()
  self.tmpRequestedPathsAlongWithAuthentication = @[account_constants.PATH_ENCRYPTION] #order is important, when reading keycard response
  if bip44Paths.len > 0:
    self.tmpRequestedPathsAlongWithAuthentication.add(bip44Paths)
    self.tmpRequestedPathsAlongWithAuthentication = self.tmpRequestedPathsAlongWithAuthentication.deduplicate()
  self.keycardService.startExportPublicFlow(self.tmpRequestedPathsAlongWithAuthentication, exportMasterAddr = false, exportPrivateAddr = true)

proc runLoadAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", pin = "", puk = "", factoryReset = false) =
  if not serviceApplicable(self.keycardService):
    return
  self.cancelCurrentFlow()
  self.keycardService.startLoadAccountFlow(seedPhraseLength, seedPhrase, pin, puk, factoryReset)

# This flow is not in use any more for authentication purpose, will be use later for signing a transaction, but
# we still do not support that. Going to keep this code, but as a comment.
#
# For running sign flow we need to be sure is a keycard we're signing with contains a keyuid for a keypair we're sending a transaction for.
#
# proc runSignFlow*(self: Controller, keyUid = "", bip44Path = "", txHash = "") =
#   if not serviceApplicable(self.keycardService):
#     return
#   self.cancelCurrentFlow()
#   self.keycardService.startSignFlow(bip44Path, txHash)

proc reRunCurrentFlow*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.reRunCurrentFlow()

proc reRunCurrentFlowLater*(self: Controller) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.reRunCurrentFlowLater()

proc readyToDisplayPopup*(self: Controller) =
  let data = SharedKeycarModuleBaseArgs(uniqueIdentifier: self.uniqueIdentifier)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP, data)

proc cleanTmpData(self: Controller) =
  # we should not reset here `tmpKeycardSyncingInProgress` property
  self.tmpKeyUidWhichIsBeingAuthenticating = ""
  self.tmpKeyUidWhichIsBeingSyncing = ""
  self.tmpAddingMigratedKeypairSuccess = false
  self.tmpConvertingProfileSuccess = false
  self.tmpCardMetadata = CardMetadata()
  self.tmpKeycardCopyCardMetadata = CardMetadata()
  self.setContainsMetadata(false)
  self.setPin("")
  self.setPinMatch(false)
  self.setPuk("")
  self.setPukMatch(false)
  self.setPukValid(false)
  self.setPassword("")
  self.setPairingCode("")
  self.setSelectedKeyPair(isProfile = false, paths = @[], KeycardDto())
  self.setSeedPhrase("")
  self.setUsePinFromBiometrics(false)
  self.setOfferToStoreUpdatedPinToKeychain(false)
  self.setKeycardUid("")
  self.setPinForKeycardCopy("")
  self.setDestinationKeycardUid("")

proc finishFlowTermination(self: Controller) =
  let data = self.tmpFlowData
  self.tmpFlowData = nil
  self.cleanTmpData()
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED, data)

proc terminateCurrentFlow*(self: Controller, lastStepInTheCurrentFlow: bool) =
  let flowType = self.delegate.getCurrentFlowType()
  self.cancelCurrentFlow()
  let (_, flowEvent) = self.getLastReceivedKeycardData()
  self.tmpFlowData = SharedKeycarModuleFlowTerminatedArgs(uniqueIdentifier: self.uniqueIdentifier,
    lastStepInTheCurrentFlow: lastStepInTheCurrentFlow)
  if lastStepInTheCurrentFlow:
    var exportedEncryptionPubKey: string
    if flowEvent.generatedWalletAccounts.len > 0:
      exportedEncryptionPubKey = flowEvent.generatedWalletAccounts[0].publicKey # encryption key is at position 0
      if exportedEncryptionPubKey.len > 0:
        self.tmpFlowData.password = exportedEncryptionPubKey
        self.tmpFlowData.pin = self.getPin()
        self.tmpFlowData.keyUid = flowEvent.keyUid
        self.tmpFlowData.keycardUid = flowEvent.instanceUID
        for i in 0..< self.tmpRequestedPathsAlongWithAuthentication.len:
          var path = self.tmpRequestedPathsAlongWithAuthentication[i]
          self.tmpFlowData.additinalPathsDetails[path] = KeyDetails(
            address: flowEvent.generatedWalletAccounts[i].address,
            publicKey: flowEvent.generatedWalletAccounts[i].publicKey,
            privateKey: flowEvent.generatedWalletAccounts[i].privateKey
          )
    else:
      self.tmpFlowData.password = self.getPassword()
      self.tmpFlowData.keyUid = singletonInstance.userProfile.getKeyUid()

  ## we're trying to sync a keycard state on popup close if:
  ## - shared module is not run from the onboarding flow
  ## - the keycard syncing is not already in progress
  ## - the flow which is terminating is one of the flows which we need to perform a sync process for
  ## - the pin is known
  if self.uniqueIdentifier != startup_io.UNIQUE_STARTUP_MODULE_IDENTIFIER and
    not self.keycardSyncingInProgress() and
    not utils.arrayContains(FlowsWeShouldNotTryAKeycardSyncFor, flowType) and
    self.getPin().len == PINLengthForStatusApp and
    flowEvent.keyUid.len > 0:
      let dataForKeycardToSync = SharedKeycarModuleArgs(pin: self.getPin(), keyUid: flowEvent.keyUid)
      self.disconnectKeycardReponseSignal()
      self.connectKeycardSyncSignal()
      self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_TRY_KEYCARD_SYNC, dataForKeycardToSync)
      return
  self.finishFlowTermination()

proc authenticateUser*(self: Controller, keyUid = "") =
  self.disconnectKeycardReponseSignal()
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: self.uniqueIdentifier,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getAccounts()

proc getKeypairs*(self: Controller): seq[wallet_account_service.KeypairDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getKeypairs()

proc getKeypairByKeyUid*(self: Controller, keyUid: string): KeypairDto =
  return self.walletAccountService.getKeypairByKeyUid(keyUid)

proc isKeyPairAlreadyAdded*(self: Controller, keyUid: string): bool =
  let keypair = self.getKeypairByKeyUid(keyUid)
  return not keypair.isNil

proc getOrFetchBalanceForAddressInPreferredCurrency*(self: Controller, address: string): tuple[balance: float64, fetched: bool] =
  if not serviceApplicable(self.walletAccountService):
    # Return 0, casuse JSON-RPC client is unavailable before user logs in.
    return (0.0, true)
  return self.walletAccountService.getOrFetchBalanceForAddressInPreferredCurrency(address)

proc addKeycardOrAccounts*(self: Controller, keyPair: KeycardDto, accountsComingFromKeycard: bool = false) =
  if not serviceApplicable(self.walletAccountService):
    return
  if not serviceApplicable(self.accountsService):
    return
  self.walletAccountService.addKeycardOrAccountsAsync(keyPair, accountsComingFromKeycard)

proc removeMigratedAccountsForKeycard*(self: Controller, keyUid: string, keycardUid: string, accountsToRemove: seq[string]) =
  if not serviceApplicable(self.walletAccountService):
    return
  self.walletAccountService.removeMigratedAccountsForKeycard(keyUid, keycardUid, accountsToRemove)

proc getAddingMigratedKeypairSuccess*(self: Controller): bool =
  return self.tmpAddingMigratedKeypairSuccess

proc getKeycardsWithSameKeyUid*(self: Controller, keyUid: string): seq[KeycardDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getKeycardsWithSameKeyUid(keyUid)

proc getAllKnownKeycards*(self: Controller): seq[KeycardDto] =
  if not serviceApplicable(self.walletAccountService):
    return
  return self.walletAccountService.getAllKnownKeycards()

proc setCurrentKeycardStateToLocked*(self: Controller, keyUid: string, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  if not self.walletAccountService.setKeycardLocked(keyUid, keycardUid):
    info "updating keycard locked state failed", keyUid=keyUid, keycardUid=keycardUid

proc setCurrentKeycardStateToUnlocked*(self: Controller, keyUid: string, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  if not self.walletAccountService.setKeycardUnlocked(keyUid, keycardUid):
    info "updating keycard unlocked state failed", keyUid=keyUid, keycardUid=keycardUid

proc updateKeycardName*(self: Controller, keycardUid: string, keycardName: string): bool =
  if not serviceApplicable(self.walletAccountService):
    return false
  if not self.walletAccountService.updateKeycardName(keycardUid, keycardName):
    info "updating keycard name failed", keycardUid=keycardUid, keycardName=keycardName
    return false
  return true

proc updateKeycardUid*(self: Controller, keyUid: string, keycardUid: string) =
  if not serviceApplicable(self.walletAccountService):
    return
  self.setCurrentKeycardStateToUnlocked(keyUid, self.tmpKeycardUid)
  if self.tmpKeycardUid != keycardUid:
    if not self.walletAccountService.updateKeycardUid(self.tmpKeycardUid, keycardUid):
      self.tmpKeycardUid = keycardUid
      info "update keycard uid failed", oldKeycardUid=self.tmpKeycardUid, newKeycardUid=keycardUid

proc addWalletAccount*(self: Controller, name, address, path, publicKey, keyUid, accountType, colorId, emoji: string): bool =
  if not serviceApplicable(self.walletAccountService):
    return false
  let err = self.walletAccountService.addWalletAccount(password = "", doPasswordHashing = false, name, address, path,
    publicKey, keyUid, accountType, colorId, emoji)
  if err.len > 0:
    info "adding wallet account failed", name=name, path=path
    return false
  return true

proc addNewSeedPhraseKeypair*(self: Controller, seedPhrase, keyUid, keypairName, rootWalletMasterKey: string,
  accounts: seq[WalletAccountDto]): bool =
  let err = self.walletAccountService.addNewSeedPhraseKeypair(seedPhrase, password = "", doPasswordHashing = false, keyUid,
    keypairName, rootWalletMasterKey, accounts)
  if err.len > 0:
    info "adding new keypair from seed phrase failed", keypairName=keypairName, keyUid=keyUid
    return false
  return true

proc getSigningPhrase*(self: Controller): string =
  if not serviceApplicable(self.settingsService):
    return
  return self.settingsService.getSigningPhrase()

proc getCurrency*(self: Controller): string =
  if not serviceApplicable(self.settingsService):
    return
  return self.settingsService.getCurrency()

proc getChainIdsOfAllKnownNetworks*(self: Controller): seq[int] =
  if not serviceApplicable(self.networkService):
    return
  return self.networkService.getNetworks().map(n => n.chainId)

proc enterKeycardPin*(self: Controller, pin: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.enterPin(pin)

proc enterKeycardPuk*(self: Controller, puk: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.enterPuk(puk)

proc storePinToKeycard*(self: Controller, pin: string, puk: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.storePin(pin, puk)

proc storePukToKeycard*(self: Controller, puk: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.storePuk(puk)

proc storePairingCodeToKeycard*(self: Controller, pairingCode: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.storePairingCode(pairingCode)

proc storeSeedPhraseToKeycard*(self: Controller, seedPhraseLength: int, seedPhrase: string) =
  if not serviceApplicable(self.keycardService):
    return
  self.keycardService.storeSeedPhrase(seedPhraseLength, seedPhrase)

proc generateRandomPUK*(self: Controller): string =
  if not serviceApplicable(self.keycardService):
    return
  return self.keycardService.generateRandomPUK()

proc isProfileMnemonicBackedUp*(self: Controller): bool =
  if not serviceApplicable(self.privacyService):
    return
  return self.privacyService.isMnemonicBackedUp()

proc getProfileMnemonic*(self: Controller): string =
  if not serviceApplicable(self.privacyService):
    return
  return self.privacyService.getMnemonic()

proc removeProfileMnemonic*(self: Controller) =
  if not serviceApplicable(self.privacyService):
    return
  self.privacyService.removeMnemonic()

proc tryToObtainDataFromKeychain*(self: Controller) =
  if not serviceApplicable(self.keychainService):
    return
  if(not singletonInstance.userProfile.getUsingBiometricLogin()):
    return
  let loggedInAccount = self.getLoggedInAccount()
  self.keychainService.tryToObtainData(loggedInAccount.keyUid)

proc tryToStoreDataToKeychain*(self: Controller, password: string) =
  if not serviceApplicable(self.keychainService):
    return
  let loggedInAccount = self.getLoggedInAccount()
  self.keychainService.storeData(loggedInAccount.keyUid, password)

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.walletAccountService.getCurrencyFormat(symbol)
