import Tables, chronicles, strutils, os
import uuids
import io_interface

import ../../../constants as main_constants
import ../../global/global_singleton
import ../../core/signals/types
import ../../core/eventemitter
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/keycard/service as keycard_service
import ../../../app_service/service/devices/service as devices_service
import ../../../app_service/common/account_constants

import ../shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "startup-controller"

type ProfileImageDetails = object
  url*: string
  croppedImage*: string
  x1*: int
  y1*: int
  x2*: int
  y2*: int

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
    tmpRecoverUsingSeedPhraseWhileLogin: bool
    tmpConnectionString: string

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
  result.tmpRecoverUsingSeedPhraseWhileLogin = false
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

proc connectToTimeoutEventAndStratTimer*(self: Controller, timeoutInMilliseconds: int) =
  var handlerId = self.events.onWithUUID(SIGNAL_GENERAL_TIMEOUT) do(e: Args):
    self.delegate.startAppAfterDelay()
  self.connectionIds.add(handlerId)
  self.generalService.runTimer(timeoutInMilliseconds)

proc disconnect*(self: Controller) =
  self.disconnectKeychain()
  for id in self.connectionIds:
    self.events.disconnect(id)

proc delete*(self: Controller) =
  self.disconnect()

proc init*(self: Controller) =
  var handlerId = self.events.onWithUUID(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    self.delegate.onNodeLogin(signal.event.error)
    self.cleanTmpData()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SignalType.NodeStopped.event) do(e:Args):
    self.events.emit("nodeStopped", Args())
    self.accountsService.clear()
    self.cleanTmpData()
    self.delegate.emitLogOut()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SignalType.NodeReady.event) do(e:Args):
    self.events.emit("nodeReady", Args())
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCARD_RESPONSE) do(e: Args):
    let args = KeycardArgs(e)
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
    self.delegate.onLocalPairingStatusUpdate(args)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_REENCRYPTION_PROCESS_STARTED) do(e: Args):
    self.delegate.onReencryptionProcessStarted()
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_LOGIN_ERROR) do(e: Args):
    let args = LoginErrorArgs(e)
    self.delegate.emitAccountLoginError(args.error)
  self.connectionIds.add(handlerId)

proc shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0

proc storeProfileDataAndProceedWithAppLoading*(self: Controller) =
  self.delegate.removeAllKeycardUidPairsForCheckingForAChangeAfterLogin() # reason for this is in the table in AppController.nim file
  self.profileService.setDisplayName(self.tmpDisplayName)
  let images = self.storeIdentityImage()
  self.accountsService.updateLoggedInAccount(self.tmpDisplayName, images)
  self.delegate.finishAppLoading()

proc checkFetchingStatusAndProceedWithAppLoading*(self: Controller) =
  self.delegate.checkFetchingStatusAndProceedWithAppLoading()

proc getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

proc getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

proc getPasswordStrengthScore*(self: Controller, password, userName: string): int =
  return self.generalService.getPasswordStrengthScore(password, userName)

proc clearImage*(self: Controller) =
  self.tmpProfileImageDetails = ProfileImageDetails()

proc generateImage*(self: Controller, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  let formatedImg = singletonInstance.utils.formatImagePath(imageUrl)
  let images = self.generalService.generateImages(formatedImg, aX, aY, bX, bY)
  if(images.len == 0):
    return
  for img in images:
    if(img.imgType == "large"):
      self.tmpProfileImageDetails = ProfileImageDetails(url: imageUrl, croppedImage: img.uri, x1: aX, y1: aY, x2: bX, y2: bY)
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

proc setDefaultWalletEmoji*(self: Controller, emoji: string) =
  self.accountsService.setDefaultWalletEmoji(emoji)

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

proc setRecoverUsingSeedPhraseWhileLogin*(self: Controller, value: bool) =
  self.tmpRecoverUsingSeedPhraseWhileLogin = value

proc getRecoverUsingSeedPhraseWhileLogin*(self: Controller): bool =
  return self.tmpRecoverUsingSeedPhraseWhileLogin

proc cleanTmpData(self: Controller) =
  self.tmpProfileImageDetails = ProfileImageDetails()
  self.tmpKeychainErrorOccurred = false
  self.setDisplayName("")
  self.setPassword("")
  self.setDefaultWalletEmoji("")
  self.setPin("")
  self.setPinMatch(false)
  self.setPuk("")
  self.setPukValid(false)
  self.setSeedPhrase("")
  self.setKeyUid("")
  self.setKeycardEvent(KeycardEvent())
  self.setRecoverUsingSeedPhraseWhileLogin(false)

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
  result = self.profileService.storeIdentityImage(account.keyUid, image, self.tmpProfileImageDetails.x1,
  self.tmpProfileImageDetails.y1, self.tmpProfileImageDetails.x2, self.tmpProfileImageDetails.y2)
  self.tmpProfileImageDetails = ProfileImageDetails()

proc validMnemonic*(self: Controller, mnemonic: string): bool =
  let err = self.accountsService.validateMnemonic(mnemonic)
  if err.len == 0:
    self.setSeedPhrase(mnemonic)
    return true
  return false

proc importMnemonic*(self: Controller): bool =
  let error = self.accountsService.importMnemonic(self.tmpSeedPhrase)
  if(error.len == 0):
    self.delegate.importAccountSuccess()
    return true
  else:
    self.delegate.emitStartupError(error, StartupErrorType.ImportAccError)
    return false

proc setupKeychain(self: Controller, store: bool) =
  if store:
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NOT_NOW)
  else:
    singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)

proc setupAccount(self: Controller, accountId: string, storeToKeychain: bool) =
  self.delegate.moveToLoadingAppState()
  let error = self.accountsService.setupAccount(accountId, self.tmpPassword, self.tmpDisplayName)
  if error != "":
    self.delegate.emitStartupError(error, StartupErrorType.SetupAccError)
  else:
    self.setupKeychain(storeToKeychain)

proc storeGeneratedAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  let accounts = self.getGeneratedAccounts()
  if accounts.len == 0:
    error "list of generated accounts is empty"
    return
  let accountId = accounts[0].id
  self.setupAccount(accountId, storeToKeychain)

proc storeImportedAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  let accountId = self.getImportedAccount().id
  self.setupAccount(accountId, storeToKeychain)

proc storeKeycardAccountAndLogin*(self: Controller, storeToKeychain: bool, newKeycard: bool) =
  if self.importMnemonic():
    self.delegate.moveToLoadingAppState()
    if newKeycard:
      self.delegate.storeDefaultKeyPairForNewKeycardUser()
      self.storeMetadataForNewKeycardUser()
    else:
      self.syncKeycardBasedOnAppWalletStateAfterLogin()
    self.accountsService.setupAccountKeycard(KeycardEvent(), self.tmpDisplayName, useImportedAcc = true)
    self.setupKeychain(storeToKeychain)
  else:
    error "an error ocurred while importing mnemonic"

proc setupKeycardAccount*(self: Controller, storeToKeychain: bool, newKeycard: bool) =
  if self.tmpSeedPhrase.len > 0:
    # if `tmpSeedPhrase` is not empty means user has recovered keycard via seed phrase
    self.storeKeycardAccountAndLogin(storeToKeychain, newKeycard)
  else:
    if self.tmpKeycardEvent.keyUid.len == 0 or
      self.accountsService.openedAccountsContainsKeyUid(self.tmpKeycardEvent.keyUid):
        self.delegate.emitStartupError(ACCOUNT_ALREADY_EXISTS_ERROR, StartupErrorType.ImportAccError)
        return
    self.delegate.moveToLoadingAppState()
    if newKeycard:
      self.delegate.storeDefaultKeyPairForNewKeycardUser()
    else:
      self.syncKeycardBasedOnAppWalletStateAfterLogin()
    self.accountsService.setupAccountKeycard(self.tmpKeycardEvent, self.tmpDisplayName, useImportedAcc = false)
    self.setupKeychain(storeToKeychain)

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

proc login*(self: Controller) =
  self.delegate.moveToLoadingAppState()
  let selectedAccount = self.getSelectedLoginAccount()
  self.accountsService.login(selectedAccount, self.tmpPassword)

proc loginAccountKeycard*(self: Controller, storeToKeychainValue: string, syncWalletAfterLogin = false) =
  if syncWalletAfterLogin:
    self.syncKeycardBasedOnAppWalletStateAfterLogin()
  singletonInstance.localAccountSettings.setStoreToKeychainValue(storeToKeychainValue)
  self.delegate.moveToLoadingAppState()
  let selAcc = self.getSelectedLoginAccount()
  let error = self.accountsService.loginAccountKeycard(selAcc, self.tmpKeycardEvent)
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)

proc loginAccountKeycardUsingSeedPhrase*(self: Controller, storeToKeychain: bool) =
  let acc = self.accountsService.createAccountFromMnemonic(self.getSeedPhrase(), includeEncryption = true, includeWhisper = true)
  let selAcc = self.getSelectedLoginAccount()

  var kcData = KeycardEvent(
    keyUid: acc.keyUid,
    masterKey: KeyDetails(address: acc.address),
    whisperKey: KeyDetails(privateKey: acc.derivedAccounts.whisper.privateKey),
    encryptionKey: KeyDetails(publicKey: acc.derivedAccounts.encryption.publicKey)
  )
  if acc.derivedAccounts.whisper.privateKey.startsWith("0x"):
    kcData.whisperKey.privateKey = acc.derivedAccounts.whisper.privateKey[2..^1]

  self.setupKeychain(storeToKeychain)

  self.delegate.moveToLoadingAppState()
  let error = self.accountsService.loginAccountKeycard(selAcc, kcData)
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)

proc convertToRegularAccount*(self: Controller): string =
  let acc = self.accountsService.createAccountFromMnemonic(self.getSeedPhrase(), includeEncryption = true)
  return self.accountsService.convertToRegularAccount(self.getSeedPhrase(), acc.derivedAccounts.encryption.publicKey, self.getPassword())
proc getKeyUidForSeedPhrase*(self: Controller, seedPhrase: string): string =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid

proc getCurrentKeycardServiceFlow*(self: Controller): keycard_service.KCSFlowType =
  return self.keycardService.getCurrentFlow()

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  return self.keycardService.getLastReceivedKeycardData()

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one,
  # this way we're giving to the keycard some time to cancel the current flow
  sleep(200)

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

proc storeMetadataForNewKeycardUser(self: Controller) =
  ## Stores metadata, default Status account only, to the keycard for a newly created keycard user.
  let paths = @[account_constants.PATH_DEFAULT_WALLET]
  self.runStoreMetadataFlow(self.getDisplayName(), self.getPin(), paths)

proc getConnectionString*(self: Controller): string =
  return self.tmpConnectionString

proc setConnectionString*(self: Controller, connectionString: string) =
  self.tmpConnectionString = connectionString

proc validateLocalPairingConnectionString*(self: Controller, connectionString: string): string =
  return self.devicesService.validateConnectionString(connectionString)

proc inputConnectionStringForBootstrapping*(self: Controller, connectionString: string): string =
  return self.devicesService.inputConnectionStringForBootstrapping(connectionString)
