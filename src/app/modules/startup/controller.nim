import chronicles, strutils, os
import uuids
import io_interface

import ../../global/global_singleton
import ../../core/signals/types
import ../../core/eventemitter
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/keycard/service as keycard_service

import ../shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "startup-controller"

const UNIQUE_STARTUP_MODULE_IDENTIFIER* = "SartupModule"

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
    connectionIds: seq[UUID]
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
    tmpKeychainErrorOccurred: bool
    tmpRecoverUsingSeedPhraseWhileLogin: bool

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  generalService: general_service.Service,
  accountsService: accounts_service.Service,
  keychainService: keychain_service.Service,
  profileService: profile_service.Service,
  keycardService: keycard_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.generalService = generalService
  result.accountsService = accountsService
  result.keychainService = keychainService
  result.profileService = profileService
  result.keycardService = keycardService
  result.tmpPinMatch = false
  result.tmpSeedPhraseLength = 0
  result.tmpKeychainErrorOccurred = true
  result.tmpRecoverUsingSeedPhraseWhileLogin = false
  result.tmpSelectedLoginAccountIsKeycardAccount = false

# Forward declaration
proc cleanTmpData*(self: Controller)

proc disconnect*(self: Controller) =
  for id in self.connectionIds:
    self.events.disconnect(id)

proc delete*(self: Controller) =
  self.disconnect()

proc init*(self: Controller) =
  var handlerId = self.events.onWithUUID(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    self.delegate.onNodeLogin(signal.event.error)
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

  handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.emitObtainingPasswordSuccess(args.data)
  self.connectionIds.add(handlerId)

  handlerId = self.events.onWithUUID(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.tmpKeychainErrorOccurred = true
    self.delegate.emitObtainingPasswordError(args.errDescription, args.errType)
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

proc shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0

proc getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

proc getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

proc getPasswordStrengthScore*(self: Controller, password, userName: string): int = 
  return self.generalService.getPasswordStrengthScore(password, userName)

proc generateImage*(self: Controller, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  let formatedImg = singletonInstance.utils.formatImagePath(imageUrl)
  let images = self.generalService.generateImages(formatedImg, aX, aY, bX, bY)
  if(images.len == 0):
    return
  for img in images:
    if(img.imgType == "large"):
      self.tmpProfileImageDetails = ProfileImageDetails(url: imageUrl, croppedImage: img.uri, x1: aX, y1: aY, x2: bX, y2: bY)
      return img.uri

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

proc setKeycardEvent*(self: Controller, value: KeycardEvent) =
  self.tmpKeycardEvent = value

proc keychainErrorOccurred*(self: Controller): bool =
  return self.tmpKeychainErrorOccurred

proc setRecoverUsingSeedPhraseWhileLogin*(self: Controller, value: bool) =
  self.tmpRecoverUsingSeedPhraseWhileLogin = value

proc getRecoverUsingSeedPhraseWhileLogin*(self: Controller): bool =
  return self.tmpRecoverUsingSeedPhraseWhileLogin

proc cleanTmpData*(self: Controller) =
  self.tmpSelectedLoginAccountKeyUid = ""
  self.tmpSelectedLoginAccountIsKeycardAccount = false
  self.tmpProfileImageDetails = ProfileImageDetails()
  self.tmpKeychainErrorOccurred = true
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

proc storePasswordToKeychain(self: Controller) =
  let account = self.accountsService.getLoggedInAccount()
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE or account.name.len == 0):
    return
  #TODO: we should store PubKey of this account instead of display name (display name is not unique)
  #      and we may run into a problem if 2 accounts with the same display name are generated.
  let data = if self.tmpPassword.len > 0: self.tmpPassword else: self.tmpPin
  self.keychainService.storeData(account.name, data)

proc storeIdentityImage*(self: Controller) =
  if self.tmpProfileImageDetails.url.len == 0:
    return
  let account = self.accountsService.getLoggedInAccount()
  let image = singletonInstance.utils.formatImagePath(self.tmpProfileImageDetails.url)
  self.profileService.storeIdentityImage(account.keyUid, image, self.tmpProfileImageDetails.x1, 
  self.tmpProfileImageDetails.y1, self.tmpProfileImageDetails.x2, self.tmpProfileImageDetails.y2)
  self.tmpProfileImageDetails = ProfileImageDetails()

proc validMnemonic*(self: Controller, mnemonic: string): bool =
  let err = self.accountsService.validateMnemonic(mnemonic)
  if err.len == 0:
    self.setSeedPhrase(mnemonic)
    return true
  return false

proc importMnemonic(self: Controller): bool =
  let error = self.accountsService.importMnemonic(self.tmpSeedPhrase)
  if(error.len == 0):
    self.delegate.importAccountSuccess()
    return true
  else:
    self.delegate.importAccountError(error)
    return false

proc setupAccount(self: Controller, accountId: string, storeToKeychain: bool, keycardUsage: bool) =
  self.delegate.moveToLoadingAppState()
  let error = self.accountsService.setupAccount(accountId, self.tmpPassword, self.tmpDisplayName, keycardUsage)
  if error != "":
    self.delegate.setupAccountError(error)
  else:
    if storeToKeychain:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_STORE)
      self.storePasswordToKeychain()
    else:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)

proc storeGeneratedAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  let accounts = self.getGeneratedAccounts()
  if accounts.len == 0:
    error "list of generated accounts is empty"
    return
  let accountId = accounts[0].id
  self.setupAccount(accountId, storeToKeychain, keycardUsage = false)

proc storeImportedAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  let accountId = self.getImportedAccount().id
  self.setupAccount(accountId, storeToKeychain, keycardUsage = false)

proc storeKeycardAccountAndLogin*(self: Controller, storeToKeychain: bool) =
  if self.importMnemonic():
    let accountId = self.getImportedAccount().id
    self.setupAccount(accountId, storeToKeychain, keycardUsage = true)
  else:
    error "an error ocurred while importing mnemonic"

proc setupKeycardAccount*(self: Controller, storeToKeychain: bool) =
  if self.tmpSeedPhrase.len > 0:
    # if `tmpSeedPhrase` is not empty means user has recovered keycard via seed phrase
    self.storeKeycardAccountAndLogin(storeToKeychain)
  else:
    self.delegate.moveToLoadingAppState()
    self.accountsService.setupAccountKeycard(self.tmpKeycardEvent)
    if storeToKeychain:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_STORE)
      self.storePasswordToKeychain()
    else:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)

proc getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

proc getSelectedLoginAccount(self: Controller): AccountDto =
  let openedAccounts = self.getOpenedAccounts()
  for acc in openedAccounts:
    if(acc.keyUid == self.tmpSelectedLoginAccountKeyUid):
      return acc

proc keyUidMatch*(self: Controller, keyUid: string): bool =
  return self.tmpSelectedLoginAccountKeyUid == keyUid

proc isSelectedLoginAccountKeycardAccount*(self: Controller): bool =
  return self.tmpSelectedLoginAccountIsKeycardAccount

proc setSelectedLoginAccount*(self: Controller, keyUid: string, isKeycardAccount: bool) =
  self.tmpSelectedLoginAccountKeyUid = keyUid
  self.tmpSelectedLoginAccountIsKeycardAccount = isKeycardAccount
  let selectedAccount = self.getSelectedLoginAccount()
  singletonInstance.localAccountSettings.setFileName(selectedAccount.name)

proc isKeycardCreatedAccountSelectedOne*(self: Controller): bool =
  let selectedAccount = self.getSelectedLoginAccount()
  return selectedAccount.keycardPairing.len > 0

proc tryToObtainDataFromKeychain*(self: Controller) =
  # Dealing with Keychain is the MacOS only feature
  if(not defined(macosx)):
    return
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE):
    return
  self.tmpKeychainErrorOccurred = false
  let selectedAccount = self.getSelectedLoginAccount()
  self.keychainService.tryToObtainData(selectedAccount.name)

proc login*(self: Controller) =
  self.delegate.moveToLoadingAppState()
  let selectedAccount = self.getSelectedLoginAccount()
  let error = self.accountsService.login(selectedAccount, self.tmpPassword)
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)

proc loginAccountKeycard*(self: Controller) =
  self.delegate.moveToLoadingAppState()
  let error = self.accountsService.loginAccountKeycard(self.tmpKeycardEvent)
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)

proc getKeyUidForSeedPhrase*(self: Controller, seedPhrase: string): string =
  let acc = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return acc.keyUid

proc seedPhraseRefersToSelectedKeyPair*(self: Controller, seedPhrase: string): bool =
  let selectedAccount = self.getSelectedLoginAccount()
  let accFromSP = self.accountsService.createAccountFromMnemonic(seedPhrase)
  return selectedAccount.keyUid == accFromSP.keyUid

proc getLastReceivedKeycardData*(self: Controller): tuple[flowType: string, flowEvent: KeycardEvent] =
  return self.keycardService.getLastReceivedKeycardData()

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()
  # in most cases we're running another flow after canceling the current one, 
  # this way we're giving to the keycard some time to cancel the current flow 
  sleep(200)

proc runLoadAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", puk = "", factoryReset = false) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoadAccountFlow(seedPhraseLength, seedPhrase, puk, factoryReset)

proc runLoginFlow*(self: Controller) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoginFlow()

proc startLoginFlowAutomatically*(self: Controller, pin: string) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startLoginFlowAutomatically(pin)

proc runRecoverAccountFlow*(self: Controller, seedPhraseLength = 0, seedPhrase = "", puk = "", factoryReset = false) =
  self.cancelCurrentFlow() # before running into any flow we're making sure that the previous flow is canceled
  self.keycardService.startRecoverAccountFlow(seedPhraseLength, seedPhrase, puk, factoryReset)

proc resumeCurrentFlow*(self: Controller) =
  self.keycardService.resumeCurrentFlow()

proc resumeCurrentFlowLater*(self: Controller) =
  self.keycardService.resumeCurrentFlowLater()

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
