import NimQml, chronicles

import io_interface
import view, controller
import internal/[state, state_factory]
import models/generated_account_item as gen_acc_item
import models/login_account_item as login_acc_item
import ../../global/global_singleton
import ../../core/eventemitter

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/keycard/service as keycard_service

import ../shared_modules/keycard_popup/module as keycard_shared_module

export io_interface

logScope:
  topics = "startup-module"

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    events: EventEmitter
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service
    keychainService: keychain_service.Service
    keycardSharedModule: keycard_shared_module.AccessInterface

proc newModule*[T](delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  generalService: general_service.Service,
  profileService: profile_service.Service,
  keycardService: keycard_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.keychainService = keychainService
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, generalService, accountsService, keychainService,
  profileService, keycardService)

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete

proc extractImages(self: Module, account: AccountDto, thumbnailImage: var string,
  largeImage: var string) =
  for img in account.images:
    if(img.imgType == "thumbnail"):
      thumbnailImage = img.uri
    elif(img.imgType == "large"):
      largeImage = img.uri

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("startupModule", self.viewVariant)
  self.controller.init()

  let generatedAccounts = self.controller.getGeneratedAccounts()
  var accounts: seq[gen_acc_item.Item]
  for acc in generatedAccounts:
    accounts.add(gen_acc_item.initItem(acc.id, acc.alias, acc.address, acc.derivedAccounts.whisper.publicKey, acc.keyUid))
  self.view.setGeneratedAccountList(accounts)

  if(self.controller.shouldStartWithOnboardingScreen()):
    if defined(macosx):
      self.view.setCurrentStartupState(newNotificationState(FlowType.General, nil))
    else:
      self.view.setCurrentStartupState(newWelcomeState(FlowType.General, nil))
  else:
    let openedAccounts = self.controller.getOpenedAccounts()
    var items: seq[login_acc_item.Item]
    for acc in openedAccounts:
      var thumbnailImage: string
      var largeImage: string
      self.extractImages(acc, thumbnailImage, largeImage)
      items.add(login_acc_item.initItem(acc.name, thumbnailImage, largeImage, acc.keyUid, acc.colorHash, acc.colorId, 
      acc.keycardPairing))
    self.view.setLoginAccountsModelItems(items)
    # set the first account as slected one
    if items.len == 0:
      # we should never be here, since else block of `if (shouldStartWithOnboardingScreen)` 
      # ensures that `openedAccounts` is not empty array
      error "cannot run the app in login flow cause list of login accounts is empty"
      quit() # quit the app
    self.setSelectedLoginAccount(items[0])
  self.delegate.startupDidLoad()

method getKeycardSharedModule*[T](self: Module[T]): QVariant =
  return self.keycardSharedModule.getModuleAsVariant()

proc createSharedKeycardModule[T](self: Module[T]) =
  self.keycardSharedModule = keycard_shared_module.newModule[Module[T]](self, UNIQUE_STARTUP_MODULE_IDENTIFIER, 
    self.events, self.keycardService, settingsService = nil, privacyService = nil, self.accountsService, 
    walletAccountService = nil, self.keychainService)

proc isSharedKeycardModuleFlowRunning[T](self: Module[T]): bool =
  return not self.keycardSharedModule.isNil

method moveToLoadingAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.AppLoadingState)

method moveToAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.MainAppState)

method startUpUIRaised*[T](self: Module[T]) =
  self.view.startUpUIRaised()

method emitLogOut*[T](self: Module[T]) =
  self.view.emitLogOut()

method onBackActionClicked*[T](self: Module[T]) =
  self.onSharedKeycarModuleFlowTerminated(lastStepInTheCurrentFlow = true)
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "back_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeBackCommand(self.controller)
  let backState = currStateObj.getBackState()
  self.view.setCurrentStartupState(backState)
  debug "back_action - set state", setCurrFlow=backState.flowType(), newCurrState=backState.stateType()
  currStateObj.delete()    
    
method onPrimaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "primary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executePrimaryCommand(self.controller)
  let nextState = currStateObj.getNextPrimaryState(self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "primary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onSecondaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "secondary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeSecondaryCommand(self.controller)
  let nextState = currStateObj.getNextSecondaryState(self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "secondary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onTertiaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "tertiary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeTertiaryCommand(self.controller)
  let nextState = currStateObj.getNextTertiaryState(self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "tertiary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method getImportedAccount*[T](self: Module[T]): GeneratedAccountDto =
  return self.controller.getImportedAccount()

method generateImage*[T](self: Module[T], imageUrl: string, aX: int, aY: int, bX: int, bY: int): string =
  return self.controller.generateImage(imageUrl, aX, aY, bX, bY)

method getCroppedProfileImage*[T](self: Module[T]): string =
  return self.controller.getCroppedProfileImage()

method setDisplayName*[T](self: Module[T], value: string) =
  self.controller.setDisplayName(value)

method getDisplayName*[T](self: Module[T]): string =
  return self.controller.getDisplayName()

method setPassword*[T](self: Module[T], value: string) =
  self.controller.setPassword(value)

method setDefaultWalletEmoji*[T](self: Module[T], emoji: string) =
  self.controller.setDefaultWalletEmoji(emoji)

method getPassword*[T](self: Module[T]): string =
  return self.controller.getPassword()

method setPin*[T](self: Module[T], value: string) =
  self.controller.setPin(value)

method setPuk*[T](self: Module[T], value: string) =
  self.controller.setPuk(value)

method getPin*[T](self: Module[T]): string =
  return self.controller.getPin()

method getPasswordStrengthScore*[T](self: Module[T], password, userName: string): int =
  return self.controller.getPasswordStrengthScore(password, userName)

method setupAccountError*[T](self: Module[T], error: string) =
  self.view.setupAccountError(error)

method validMnemonic*[T](self: Module[T], mnemonic: string): bool =
  return self.controller.validMnemonic(mnemonic)

method importAccountError*[T](self: Module[T], error: string) =
  self.view.importAccountError(error)

method importAccountSuccess*[T](self: Module[T]) =
  self.view.importAccountSuccess()

method setSelectedLoginAccount*[T](self: Module[T], item: login_acc_item.Item) =
  self.controller.cancelCurrentFlow()
  self.controller.setSelectedLoginAccount(item.getKeyUid(), item.getKeycardCreatedAccount())
  self.view.setCurrentStartupState(newLoginState(FlowType.AppLogin, nil))
  if item.getKeycardCreatedAccount():
    self.controller.runLoginFlow()
  else:  
    self.controller.tryToObtainDataFromKeychain()
  self.view.setSelectedLoginAccount(item)

method emitAccountLoginError*[T](self: Module[T], error: string) =
  self.view.emitAccountLoginError(error)

method emitObtainingPasswordError*[T](self: Module[T], errorDescription: string, errorType: string) =
  self.view.emitObtainingPasswordError(errorDescription, errorType)

method emitObtainingPasswordSuccess*[T](self: Module[T], password: string) =
  self.view.emitObtainingPasswordSuccess(password)

method onNodeLogin*[T](self: Module[T], error: string) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot determine current startup state"
    quit() # quit the app

  if error.len == 0:
    self.delegate.userLoggedIn()
    if currStateObj.flowType() != FlowType.AppLogin:
      self.controller.storeIdentityImage()
    self.controller.cleanTmpData()
  else:
    self.view.setAppState(AppState.StartupState)
    if currStateObj.flowType() == FlowType.AppLogin:
      self.emitAccountLoginError(error)
    else:
      self.setupAccountError(error)
    error "login error", methodName="onNodeLogin", errDesription =error

method onKeycardResponse*[T](self: Module[T], keycardFlowType: string, keycardEvent: KeycardEvent) =
  if self.isSharedKeycardModuleFlowRunning():
    debug "shared flow is currently active"
    return
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "on_keycard_response", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  let nextState = currStateObj.resolveKeycardNextState(keycardFlowType, keycardEvent, self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "on_keycard_response - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method checkRepeatedKeycardPinWhileTyping*[T](self: Module[T], pin: string): bool =
  self.controller.setPinMatch(false)
  let storedPin = self.controller.getPin()
  if pin.len > storedPin.len:
    return false
  elif pin.len < storedPin.len:
    for i in 0 ..< pin.len:
      if pin[i] != storedPin[i]:
        return false
    return true
  else: 
    let match = pin == storedPin
    self.controller.setPinMatch(match)
    return match

method getSeedPhrase*[T](self: Module[T]): string =
  return self.controller.getSeedPhrase()

method setKeycardData*[T](self: Module[T], value: string) =
  self.view.setKeycardData(value)

method runFactoryResetPopup*[T](self: Module[T]) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.FactoryReset)
  
method onDisplayKeycardSharedModuleFlow*[T](self: Module[T]) =
  self.view.emitDisplayKeycardSharedModuleFlow()

method onSharedKeycarModuleFlowTerminated*[T](self: Module[T], lastStepInTheCurrentFlow: bool) =
  if self.isSharedKeycardModuleFlowRunning():
    self.controller.cancelCurrentFlow()
    self.view.emitDestroyKeycardSharedModuleFlow()
    self.keycardSharedModule.delete
    self.keycardSharedModule = nil
    if lastStepInTheCurrentFlow:
      self.controller.cleanTmpData()
      self.view.setCurrentStartupState(newWelcomeState(FlowType.General, nil))
