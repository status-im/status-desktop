import Tables, chronicles, strutils
import uuids
import io_interface

import constants as main_constants
import app/global/global_singleton
import app/core/signals/types
import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/accounts/service as accounts_service
import app_service/service/keychain/service as keychain_service
import app_service/service/profile/service as profile_service
import app_service/service/keycard/service as keycard_service
import app_service/service/devices/service as devices_service
import app_service/common/[account_constants, utils]
import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

import app_service/service/accounts/dto/create_account_request

logScope:
  topics = "startup-controller"

type ProfileImageDetails = object
  url*: string
  croppedImage*: string
  cropRectangle*: ImageCropRectangle

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    generalService: general_service.Service
    accountsService: accounts_service.Service
    keychainService: keychain_service.Service
    profileService: profile_service.Service
    keycardService: keycard_service.Service
    devicesService: devices_service.Service
    connectionIds: seq[UUID]
    keychainConnectionIds: seq[UUID]
    tmpProfileImageDetails: ProfileImageDetails
    tmpDisplayName: string
    tmpPassword: string
    tmpSelectedLoginAccountKeyUid: string
    tmpSelectedLoginAccountIsKeycardAccount: bool
    tmpPin: string
    tmpPinMatch: bool
    tmpPuk: string
    tmpValidPuk: bool
    tmpSeedPhrase: string
    tmpSeedPhraseLength: int
    tmpKeyUid: string
    tmpKeycardEvent: KeycardEvent
    tmpCardMetadata: CardMetadata
    tmpKeychainErrorOccurred: bool
    tmpRecoverKeycardUsingSeedPhraseWhileLoggingIn: bool
    tmpConnectionString: string
    localPairingStatus: LocalPairingStatus
    loggedInPofilePublicKey: string

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  generalService: general_service.Service,
  accountsService: accounts_service.Service,
  keychainService: keychain_service.Service,
  profileService: profile_service.Service,
  keycardService: keycard_service.Service,
  devicesService: devices_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.generalService = generalService
  result.accountsService = accountsService
  result.keychainService = keychainService
  result.profileService = profileService
  result.keycardService = keycardService
  result.devicesService = devicesService
  result.tmpPinMatch = false
  result.tmpSeedPhraseLength = 0
  result.tmpKeychainErrorOccurred = false
  result.tmpRecoverKeycardUsingSeedPhraseWhileLoggingIn = false
  result.tmpSelectedLoginAccountIsKeycardAccount = false

# Forward declaration
proc cleanTmpData(self: Controller)
proc storeMetadataForNewKeycardUser(self: Controller)
proc storeIdentityImage*(self: Controller): seq[Image]
proc getSelectedLoginAccount*(self: Controller): AccountDto

proc disconnectKeychain(self: Controller) =
  for id in self.keychainConnectionIds:
    self.events.disconnect(id)
  self.keychainConnectionIds = @[]

proc connectKeychain(self: Controller) =
  var handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.disconnectKeychain()
    self.delegate.emitObtainingPasswordSuccess(args.data)
  self.keychainConnectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.tmpKeychainErrorOccurred = true
    self.disconnectKeychain()
    self.delegate.emitObtainingPasswordError(args.errDescription, args.errType)
  self.keychainConnectionIds.add(handlerId)

proc connectToFetchingFromWakuEvents*(self: Controller) =
  self.accountsService.connectToFetchingFromWakuEvents()

  var handlerId = self.events.onWithUUID(SignalType.WakuFetchingBackupProgress.event) do(e: Args):
    var receivedData = WakuFetchingBackupProgressSignal(e)
    for k, v in receivedData.fetchingBackupProgress:
      self.delegate.onFetchingFromWakuMessageReceived(receivedData.clock, k, v.totalNumber, v.dataNumber)
  self.connectionIds.add(handlerId)

proc disconnect*(self: Controller) =
  self.disconnectKeychain()
  for id in self.connectionIds:
    self.events.disconnect(id)

proc delete*(self: Controller) =
  self.disconnect()
  self.cleanTmpData()

proc init*(self: Controller) =
  var handlerId = self.events.onWithUUID(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    self.delegate.onNodeLogin(signal.error, signal.account, signal.settings)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SignalType.NodeStopped.event) do(e:Args):
    self.events.emit("nodeStopped", Args())
    self.accountsService.clear()
    self.cleanTmpData()
    self.delegate.emitLogOut()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCARD_RESPONSE) do(e: Args):
    let args = KeycardLibArgs(e)
    self.delegate.onKeycardResponse(args.flowType, args.flowEvent)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED) do(e: Args):
    let args = SharedKeycarModuleFlowTerminatedArgs(e)
    if args.uniqueIdentifier != UNIQUE_STARTUP_MODULE_IDENTIFIER:
      return
    self.delegate.onSharedKeycarModuleFlowTerminated(args.lastStepInTheCurrentFlow)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP) do(e: Args):
    let args = SharedKeycarModuleBaseArgs(e)
    if args.uniqueIdentifier != UNIQUE_STARTUP_MODULE_IDENTIFIER:
      return
    self.delegate.onDisplayKeycardSharedModuleFlow()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_LOCAL_PAIRING_STATUS_UPDATE) do(e: Args):
    let args = LocalPairingStatus(e)
    if args.pairingType != PairingType.AppSync:
      return
    self.localPairingStatus = args
    self.delegate.onLocalPairingStatusUpdate(self.localPairingStatus)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SignalType.DBReEncryptionStarted.event) do(e: Args):
    self.delegate.onReencryptionProcessStarted()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SignalType.DBReEncryptionFinished.event) do(e: Args):
    self.delegate.onReencryptionProcessFinished()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_LOGIN_ERROR) do(e: Args):
    let args = LoginErrorArgs(e)
    self.delegate.emitAccountLoginError(args.error)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_CONVERTING_PROFILE_KEYPAIR) do(e: Args):
    let args = ResultArgs(e)
    self.delegate.onProfileConverted(args.success)
  self.connectionIds.add(handlerId)

proc shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0

# This is used in 2 flows, in case fetching backup failed and we create a new displayName and profileImage:
#   1. FirstRunOldUserImportSeedPhrase
#   2. FirstRunOldUserKeycardImport
# At this point the account is already created in the database. All that's left is to set the displayName and profileImage.
proc storeProfileDataAndProceedWithAppLoading*(self: Controller) =
  self.delegate.removeAllKeycardUidPairsForCheckingForAChangeAfterLogin() # reason for this is in the table in AppController.nim file
  discard self.profileService.setDisplayName(self.tmpDisplayName)
  let images = self.storeIdentityImage()
  self.accountsService.updateLoggedInAccount(self.tmpDisplayName, images)
  self.delegate.notifyLoggedInAccountChanged()

proc checkFetchingStatusAndProceed*(self: Controller) =
  self.delegate.checkFetchingStatusAndProceed()

proc getPasswordStrengthScore*(self: Controller, password, userName: string): int =
  return self.generalService.getPasswordStrengthScore(password, userName)

proc clearImage*(self: Controller) =
  self.tmpProfileImageDetails = ProfileImageDetails()

proc generateImage*(self: Controller, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  let formatedImg = singletonInstance.utils.formatImagePath(imageUrl)
  let images = self.generalService.generateImages(formatedImg, aX, aY, bX, bY)
  if images.len == 0:
    return
  for img in images:
    if img.imgType == "large":
      self.tmpProfileImageDetails = ProfileImageDetails(
        url: formatedImg, 
        croppedImage: img.uri, 
        cropRectangle: ImageCropRectangle(ax: aX, ay: aY, bx: bX, by: bY)
      )
      return img.uri

proc fetchWakuMessages*(self: Controller) =
  self.generalService.fetchWakuMessages()

proc getCroppedProfileImage*(self: Controller): string =
  return self.tmpProfileImageDetails.croppedImage

proc setDisplayName*(self: Controller, value: string) =
  self.tmpDisplayName = value

proc getDisplayName*(self: Controller): string =
  return self.tmpDisplayName

proc setPassword*(self: Controller, value: string) =
  self.tmpPassword = value

proc getPassword*(self: Controller): string =
  return self.tmpPassword

proc setPin*(self: Controller, value: string) =
  self.tmpPin = value

proc getPin*(self: Controller): string =
  return self.tmpPin

proc setPinMatch*(self: Controller, value: bool) =
  self.tmpPinMatch = value

proc getPinMatch*(self: Controller): bool =
  return self.tmpPinMatch

proc setPuk*(self: Controller, value: string) =
  self.tmpPuk = value

proc getPuk*(self: Controller): string =
  return self.tmpPuk

proc setPukValid*(self: Controller, value: bool) =
  self.tmpValidPuk = value

proc getValidPuk*(self: Controller): bool =
  return self.tmpValidPuk

proc setSeedPhrase*(self: Controller, value: string) =
  let words = value.split(" ")
  self.tmpSeedPhrase = value
  self.tmpSeedPhraseLength = words.len

proc getSeedPhrase*(self: Controller): string =
  return self.tmpSeedPhrase

proc getSeedPhraseLength*(self: Controller): int =
  return self.tmpSeedPhraseLength

proc setKeyUid*(self: Controller, value: string) =
  self.tmpKeyUid = value

proc getKeyUid*(self: Controller): string =
  self.tmpKeyUid

proc getKeycardData*(self: Controller): string =
  return self.delegate.getKeycardData()

proc setKeycardData*(self: Controller, value: string) =
  self.delegate.setKeycardData(value)

proc setRemainingAttempts*(self: Controller, value: int) =
  self.delegate.setRemainingAttempts(value)

proc setKeycardEvent*(self: Controller, value: KeycardEvent) =
  self.tmpKeycardEvent = value

proc setMetadataFromKeycard*(self: Controller, cardMetadata: CardMetadata) =
  self.tmpCardMetadata = cardMetadata

proc getMetadataFromKeycard*(self: Controller): CardMetadata =
  return self.tmpCardMetadata

proc addToKeycardUidPairsToCheckForAChangeAfterLogin*(self: Controller, oldKeycardUid: string, newKeycardUid: string) =
  self.delegate.addToKeycardUidPairsToCheckForAChangeAfterLogin(oldKeycardUid, newKeycardUid)

proc syncKeycardBasedOnAppWalletStateAfterLogin(self: Controller) =
  self.delegate.syncKeycardBasedOnAppWalletStateAfterLogin()

proc keychainErrorOccurred*(self: Controller): bool =
  return self.tmpKeychainErrorOccurred

proc setRecoverKeycardUsingSeedPhraseWhileLoggingIn*(self: Controller, value: bool) =
  self.tmpRecoverKeycardUsingSeedPhraseWhileLoggingIn = value

proc getRecoverKeycardUsingSeedPhraseWhileLoggingIn*(self: Controller): bool =
  return self.tmpRecoverKeycardUsingSeedPhraseWhileLoggingIn

proc cleanTmpData(self: Controller) =
  self.tmpProfileImageDetails = ProfileImageDetails()
  self.tmpKeychainErrorOccurred = false
  self.setDisplayName("")
  self.setPassword("")
  self.setPin("")
  self.setPinMatch(false)
  self.setPuk("")
  self.setPukValid(false)
  self.setSeedPhrase("")
  self.setKeyUid("")
  self.setKeycardEvent(KeycardEvent())
  self.setRecoverKeycardUsingSeedPhraseWhileLoggingIn(false)

proc tryToObtainDataFromKeychain*(self: Controller) =
  ## This proc is used to fetch pass/pin from the keychain while user is trying to login.
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if not main_constants.IS_MACOS or # This is MacOS only feature
    value != LS_VALUE_STORE:
      return
  self.connectKeychain() # handling the results is done in slots connected in `connectKeychain` proc
  self.tmpKeychainErrorOccurred = false
  let selectedAccount = self.getSelectedLoginAccount()
  self.keychainService.tryToObtainData(selectedAccount.keyUid)

proc storeIdentityImage*(self: Controller): seq[Image] =
  if self.tmpProfileImageDetails.url.len == 0:
    return
  let account = self.accountsService.getLoggedInAccount()
  let image = singletonInstance.utils.formatImagePath(self.tmpProfileImageDetails.url)
  result = self.profileService.storeIdentityImage(
    account.keyUid, 
    image, 
    self.tmpProfileImageDetails.cropRectangle.aX,
    self.tmpProfileImageDetails.cropRectangle.aY,
    self.tmpProfileImageDetails.cropRectangle.bX,
    self.tmpProfileImageDetails.cropRectangle.bY,
  )
  self.tmpProfileImageDetails = ProfileImageDetails()

# validMnemonic only checks if mnemonic is valid
# This is used from UI.
proc validMnemonic*(self: Controller, mnemonic: string): bool =
  let (keyUID, err) = self.accountsService.validateMnemonic(mnemonic)
  if err.len == 0:
    self.setSeedPhrase(mnemonic)
    return true
  return false

# validateMnemonicForImport checks if mnemonic is valid and not yet saved in local database
proc validateMnemonicForImport*(self: Controller, mnemonic: string): bool =

  let (keyUID, err) = self.accountsService.validateMnemonic(mnemonic)
  if err.len != 0:
    self.delegate.emitStartupError(err, StartupErrorType.ImportAccError)
    return false

  if self.accountsService.openedAccountsContainsKeyUid(keyUID):
    self.delegate.emitStartupError(ACCOUNT_ALREADY_EXISTS_ERROR, StartupErrorType.ImportAccError)
    return false

  self.setSeedPhrase(mnemonic)
  return true

proc setupKeychain(self: Controller, store: bool) =
  if store:
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NOT_NOW)
  else:
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)

proc processCreateAccountResult*(self: Controller, error: string, displayName: string, storeToKeychain: bool) =
  if error != "":
    self.delegate.emitStartupError(error, StartupErrorType.SetupAccError)
  else:
    singletonInstance.localAccountSettings.setFileName(displayName)
    self.setupKeychain(storeToKeychain)

proc createAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  self.delegate.moveToLoadingAppState()
  let error = self.accountsService.createAccountAndLogin(
    self.tmpPassword, 
    self.tmpDisplayName, 
    self.tmpProfileImageDetails.url, 
    self.tmpProfileImageDetails.cropRectangle
  )
  self.processCreateAccountResult(error, self.tmpDisplayName, storeToKeychain)

proc importAccountAndLogin*(self: Controller, storeToKeychain: bool, recoverAccount: bool = false) =
  if recoverAccount:
    self.delegate.prepareAndInitFetchingData()
    self.connectToFetchingFromWakuEvents()
  else:
    self.delegate.moveToLoadingAppState()

  let error = self.accountsService.importAccountAndLogin(
    self.tmpSeedPhrase, 
    self.tmpPassword, 
    recoverAccount, 
    self.tmpDisplayName, 
    self.tmpProfileImageDetails.url,
    self.tmpProfileImageDetails.cropRectangle,
  )

  self.processCreateAccountResult(error, self.tmpDisplayName, storeToKeychain)

# NOTE: Called during FirstRunNewUserNewKeycardKeys and FirstRunNewUserImportSeedPhraseIntoKeycard
# WARNING: Reuse `importAccountAndLogin` with custom parameters
proc storeKeycardAccountAndLogin*(self: Controller, storeToKeychain: bool, newKeycard: bool = true) =
  self.delegate.moveToLoadingAppState()
  self.storeMetadataForNewKeycardUser()
  let (_, flowEvent) = self.keycardService.getLastReceivedKeycardData()
  let error = self.accountsService.importAccountAndLogin(
    self.tmpSeedPhrase, 
    password = "", # For keycard it will be substituted with`encryption.publicKey` in status-go
    false, 
    self.tmpDisplayName, 
    self.tmpProfileImageDetails.url,
    self.tmpProfileImageDetails.cropRectangle,
    keycardInstanceUID = flowEvent.instanceUID,
  )
  self.processCreateAccountResult(error, self.tmpDisplayName, storeToKeychain)

# NOTE: Called during FirstRunOldUserKeycardImport
proc setupKeycardAccount*(self: Controller, storeToKeychain: bool, recoverAccount: bool = false) =
  if self.tmpKeycardEvent.keyUid.len == 0 or
    self.accountsService.openedAccountsContainsKeyUid(self.tmpKeycardEvent.keyUid):
      self.delegate.emitStartupError(ACCOUNT_ALREADY_EXISTS_ERROR, StartupErrorType.ImportAccError)
      return

  if recoverAccount:
    self.delegate.prepareAndInitFetchingData()
    self.connectToFetchingFromWakuEvents()

  self.syncKeycardBasedOnAppWalletStateAfterLogin()

  let error = self.accountsService.restoreKeycardAccountAndLogin(
    self.tmpKeycardEvent,
    recoverAccount, 
    self.tmpDisplayName, 
    self.tmpProfileImageDetails.url,
    self.tmpProfileImageDetails.cropRectangle,
  )
  
  self.processCreateAccountResult(error, self.tmpDisplayName, storeToKeychain)

proc getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

proc getSelectedLoginAccount*(self: Controller): AccountDto =
  let openedAccounts = self.getOpenedAccounts()
  for acc in openedAccounts:
    if(acc.keyUid == self.tmpSelectedLoginAccountKeyUid):
      return acc

proc keyUidMatchSelectedLoginAccount*(self: Controller, keyUid: string): bool =
  return self.tmpSelectedLoginAccountKeyUid == keyUid

proc isSelectedLoginAccountKeycardAccount*(self: Controller): bool =
  return self.tmpSelectedLoginAccountIsKeycardAccount

proc setSelectedLoginAccount*(self: Controller, keyUid: string, isKeycardAccount: bool) =
  self.tmpSelectedLoginAccountKeyUid = keyUid
  self.tmpSelectedLoginAccountIsKeycardAccount = isKeycardAccount
  let selectedAccount = self.getSelectedLoginAccount()
  singletonInstance.localAccountSettings.setFileName(selectedAccount.name)

proc isSelectedAccountAKeycardAccount*(self: Controller): bool =
  let selectedAccount = self.getSelectedLoginAccount()
  return selectedAccount.keycardPairing.len > 0

proc login*(self: Controller, keycard: bool = false, keycardReplacement: bool = false) =
  self.delegate.moveToLoadingAppState()

  var passwordHash, chatPrivateKey, mnemonic = ""

  if not keycard:
    passwordHash = hashPassword(self.tmpPassword) 
  else:
    passwordHash = self.tmpKeycardEvent.encryptionKey.publicKey
    chatPrivateKey = self.tmpKeycardEvent.whisperKey.privateKey
    mnemonic = self.tmpSeedPhrase

  if keycard and keycardReplacement:
    self.delegate.applyKeycardReplacementAfterLogin()
      
  self.accountsService.login(
    self.getSelectedLoginAccount(),
    passwordHash,
    chatPrivateKey,
    mnemonic,
  )

proc loginLocalPairingAccount*(self: Controller) =
  self.delegate.moveToLoadingAppState()
  self.accountsService.login(
    self.localPairingStatus.account,
    self.localPairingStatus.password,
    chatPrivateKey = self.localPairingStatus.chatKey
  )

# FIXME: Why do we even have storeToKeychain during login? Makes no sense
# https://github.com/status-im/status-desktop/issues/15167
proc loginAccountKeycard*(self: Controller, storeToKeychain: bool, keycardReplacement = false) =
  # singletonInstance.localAccountSettings.setStoreToKeychainValue(storeToKeychainValue)
  self.login(keycard = true, keycardReplacement = keycardReplacement)

proc convertKeycardProfileKeypairToRegular*(self: Controller) =
  let acc = self.accountsService.createAccountFromMnemonic(self.getSeedPhrase(), includeEncryption = true)
  self.accountsService.convertKeycardProfileKeypairToRegular(self.getSeedPhrase(), acc.derivedAccounts.encryption.publicKey,
    self.getPassword())

proc getKeyUidForSeedPhrase*(self: Controller, seedPhrase: string): string =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid

proc getCurrentKeycardServiceFlow*(self: Controller): keycard_service.KCSFlowType =
  return self.keycardService.getCurrentFlow()

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  return self.keycardService.getLastReceivedKeycardData()

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()

proc runLoadAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", pin = "", puk = "", factoryReset = false) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoadAccountFlow(seedPhraseLength, seedPhrase, pin, puk, factoryReset)

proc runLoginFlow*(self: Controller) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoginFlow()

proc startLoginFlowAutomatically*(self: Controller, pin: string) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoginFlowAutomatically(pin)

proc runRecoverAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", puk = "", factoryReset = false) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startRecoverAccountFlow(seedPhraseLength, seedPhrase, puk, factoryReset)

proc runStoreMetadataFlow*(self: Controller, cardName: string, pin: string, walletPaths: seq[string]) =
  self.cancelCurrentFlow()
  self.keycardService.startStoreMetadataFlow(cardName, pin, walletPaths)

proc runGetMetadataFlow*(self: Controller, resolveAddress = false, exportMasterAddr = false, pin = "") =
  self.cancelCurrentFlow()
  self.keycardService.startGetMetadataFlow(resolveAddress, exportMasterAddr, pin)

proc resumeCurrentFlow*(self: Controller) =
  self.keycardService.resumeCurrentFlow()

proc reRunCurrentFlow*(self: Controller) =
  self.keycardService.reRunCurrentFlow()

proc reRunCurrentFlowLater*(self: Controller) =
  self.keycardService.reRunCurrentFlowLater()

proc runFactoryResetPopup*(self: Controller) =
  self.delegate.runFactoryResetPopup()

proc storePinToKeycard*(self: Controller, pin: string, puk: string) =
  self.keycardService.storePin(pin, puk)

proc enterKeycardPin*(self: Controller, pin: string) =
  self.keycardService.enterPin(pin)

proc enterKeycardPuk*(self: Controller, puk: string) =
  self.keycardService.enterPuk(puk)

proc storeSeedPhraseToKeycard*(self: Controller, seedPhraseLength: int, seedPhrase: string) =
  self.keycardService.storeSeedPhrase(seedPhraseLength, seedPhrase)

proc buildSeedPhrasesFromIndexes*(self: Controller, seedPhraseIndexes: seq[int]) =
  if seedPhraseIndexes.len == 0:
    let err = "cannot generate mnemonic"
    error "keycard error: ", err
    ## TODO: we should not be ever in this block, but maybe we can cancel flow and reset states (as the app was just strated)
    return
  let sp = self.keycardService.buildSeedPhrasesFromIndexes(seedPhraseIndexes)
  self.setSeedPhrase(sp.join(" "))

proc generateRandomPUK*(self: Controller): string =
  return self.keycardService.generateRandomPUK()

# Stores metadata, default Status account only, to the keycard for a newly created keycard user.
proc storeMetadataForNewKeycardUser(self: Controller) =
  let paths = @[account_constants.PATH_DEFAULT_WALLET]
  self.runStoreMetadataFlow(self.getDisplayName(), self.getPin(), paths)

proc getConnectionString*(self: Controller): string =
  return self.tmpConnectionString

proc setConnectionString*(self: Controller, connectionString: string) =
  self.tmpConnectionString = connectionString

proc validateLocalPairingConnectionString*(self: Controller, connectionString: string): string =
  return self.devicesService.validateConnectionString(connectionString)

proc inputConnectionStringForBootstrapping*(self: Controller, connectionString: string) =
  self.devicesService.inputConnectionStringForBootstrapping(connectionString)

proc setLoggedInAccount*(self: Controller, account: AccountDto) =
  self.accountsService.setLoggedInAccount(account)

proc setLoggedInProfile*(self: Controller, publicKey: string) =
  self.loggedInPofilePublicKey = publicKey

proc getLoggedInAccountPublicKey*(self: Controller): string =
  return self.loggedInPofilePublicKey

proc getLoggedInAccountDisplayName*(self: Controller): string =
  return self.accountsService.getLoggedInAccount().name

proc getLoggedInAccountImage*(self: Controller): string =
  let images = self.accountsService.getLoggedInAccount().images
  for img in images:
    if img.imgType == "large":
      return img.uri
  return ""

# NOTE: This could be a constant now, but in future we should check if the user
# has already enabled notifications and return corresponding result from this function.
proc notificationsNeedsEnable*(self: Controller): bool = 
  return main_constants.IS_MACOS

proc proceedToApp*(self: Controller) =
  self.delegate.finishAppLoading()

proc finishPairingThroughSeedPhraseProcess*(self: Controller, installationId: string) =
  self.devicesService.finishPairingThroughSeedPhraseProcess(installationId)
