import chronicles

import io_interface

import ../../global/global_singleton
import ../../core/signals/types
import ../../core/eventemitter
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/profile/service as profile_service

logScope:
  topics = "startup-controller"

type ProfileImageDetails = object
  url*: string
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
    tmpProfileImageDetails: ProfileImageDetails
    tmpDisplayName: string
    tmpPassword: string
    tmpMnemonic: string
    tmpSelectedLoginAccountKeyUid: string
    tmpStoreToKeychain: bool

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  generalService: general_service.Service,
  accountsService: accounts_service.Service,
  keychainService: keychain_service.Service,
  profileService: profile_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.generalService = generalService
  result.accountsService = accountsService
  result.keychainService = keychainService
  result.profileService = profileService

## Forward initialization
proc finalizeSettingupAccount(self: Controller, error: string)
proc finalizeLoggingInAccount(self: Controller, error: string)

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    self.delegate.onNodeLogin(signal.event.error)

  self.events.on(SignalType.NodeStopped.event) do(e:Args):
    self.events.emit("nodeStopped", Args())
    self.accountsService.clear()
    self.delegate.emitLogOut()

  self.events.on(SignalType.NodeReady.event) do(e:Args):
    self.events.emit("nodeReady", Args())

  self.events.on(SIGNAL_KEYCHAIN_SERVICE_SUCCESS) do(e:Args):
    let args = KeyChainServiceArg(e)
    self.delegate.emitObtainingPasswordSuccess(args.data)

  self.events.on(SIGNAL_KEYCHAIN_SERVICE_ERROR) do(e:Args):
    let args = KeyChainServiceArg(e)
    # We are notifying user only about keychain errors.
    if (args.errType == ERROR_TYPE_AUTHENTICATION):
      return
    singletonInstance.localAccountSettings.removeKey(LS_KEY_STORE_TO_KEYCHAIN)
    self.delegate.emitObtainingPasswordError(args.errDescription)

  self.events.on(SIGNAL_SETUP_ACCOUNT_RESPONSE) do(e:Args):
    let args = AccountsArgs(e)
    self.finalizeSettingupAccount(args.error)

  self.events.on(SIGNAL_LOGIN_ACCOUNT_RESPONSE) do(e:Args):
    let args = AccountsArgs(e)
    self.finalizeLoggingInAccount(args.error)

proc shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0

proc getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

proc getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

proc generateImages*(self: Controller, image: string, aX: int, aY: int, bX: int, bY: int): seq[general_service.Image] =
  return self.generalService.generateImages(image, aX, aY, bX, bY)

proc getPasswordStrengthScore*(self: Controller, password, userName: string): int = 
  return self.generalService.getPasswordStrengthScore(password, userName)

proc generateImage*(self: Controller, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  let formatedImg = singletonInstance.utils.formatImagePath(imageUrl)
  let images = self.generateImages(formatedImg, aX, aY, bX, bY)
  if(images.len == 0):
    return
  for img in images:
    if(img.imgType == "large"):
      self.tmpProfileImageDetails = ProfileImageDetails(url: imageUrl, x1: aX, y1: aY, x2: bX, y2: bY)
      return img.uri

proc setDisplayName*(self: Controller, value: string) =
  self.tmpDisplayName = value

proc getDisplayName*(self: Controller): string =
  return self.tmpDisplayName

proc setPassword*(self: Controller, value: string) =
  self.tmpPassword = value

proc getPassword*(self: Controller): string =
  return self.tmpPassword

proc storePasswordToKeychain(self: Controller) =
  let account = self.accountsService.getLoggedInAccount()
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE or account.name.len == 0):
    return
  self.keychainService.storePassword(account.name, self.tmpPassword)

proc storeIdentityImage*(self: Controller) =
  if self.tmpProfileImageDetails.url.len == 0:
    return
  let account = self.accountsService.getLoggedInAccount()
  let image = singletonInstance.utils.formatImagePath(self.tmpProfileImageDetails.url)
  self.profileService.storeIdentityImage(account.keyUid, image, self.tmpProfileImageDetails.x1, 
  self.tmpProfileImageDetails.y1, self.tmpProfileImageDetails.x2, self.tmpProfileImageDetails.y2)
  self.tmpProfileImageDetails = ProfileImageDetails()

proc finalizeSettingupAccount(self: Controller, error: string) =
  if error != "":
    self.delegate.setupAccountError(error)
  else:
    if self.tmpStoreToKeychain:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_STORE)
      self.storePasswordToKeychain()
    else:
      singletonInstance.localAccountSettings.setStoreToKeychainValue(LS_VALUE_NEVER)
  self.setPassword("")
  self.setDisplayName("")
  self.tmpStoreToKeychain = false  

proc setupAccount(self: Controller, accountId: string, storeToKeychain: bool) =
  self.tmpStoreToKeychain = storeToKeychain
  let error = self.accountsService.setupAccount(accountId, self.tmpPassword, self.tmpDisplayName)

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

proc validMnemonic*(self: Controller, mnemonic: string): bool =
  let err = self.accountsService.validateMnemonic(mnemonic)
  if err.len == 0:
    self.tmpMnemonic = mnemonic
    return true
  return false

proc importMnemonic*(self: Controller): bool =
  let error = self.accountsService.importMnemonic(self.tmpMnemonic)
  if(error.len == 0):
    self.delegate.importAccountSuccess()
    return true
  else:
    self.delegate.importAccountError(error)
    return false

proc getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

proc getSelectedLoginAccount(self: Controller): AccountDto =
  let openedAccounts = self.getOpenedAccounts()
  for acc in openedAccounts:
    if(acc.keyUid == self.tmpSelectedLoginAccountKeyUid):
      return acc

proc setSelectedLoginAccountKeyUid*(self: Controller, keyUid: string) =
  self.tmpSelectedLoginAccountKeyUid = keyUid
  # Dealing with Keychain is the MacOS only feature
  if(not defined(macosx)):
    return
  let selectedAccount = self.getSelectedLoginAccount()
  singletonInstance.localAccountSettings.setFileName(selectedAccount.name)
  let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
  if (value != LS_VALUE_STORE):
    return
  self.keychainService.tryToObtainPassword(selectedAccount.name)

proc finalizeLoggingInAccount(self: Controller, error: string) =
  if(error.len > 0):
    self.delegate.emitAccountLoginError(error)

proc login*(self: Controller) =
  let selectedAccount = self.getSelectedLoginAccount()
  self.accountsService.login(selectedAccount, self.tmpPassword)
  self.setPassword("")