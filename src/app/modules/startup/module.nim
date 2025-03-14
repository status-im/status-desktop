import NimQml, chronicles, json

import io_interface
import view, controller
import internal/[state, state_factory]
import models/login_account_item as login_acc_item
import models/fetching_data_model as fetch_model
import app/global/global_singleton
import app/core/eventemitter

import constants as main_constants
import app/global/app_translatable_constants as atc

const dummyUsage = main_constants.IS_MACOS # dummy usage to prevent false-alarm warning
const dummyUsage2 = atc.LOGIN_ACCOUNTS_LIST_ADD_NEW_USER # dummy usage to prevent false-alarm warning

import app_service/service/keychain/service as keychain_service
import app_service/service/accounts/service as accounts_service
import app_service/service/general/service as general_service
import app_service/service/profile/service as profile_service
import app_service/service/keycard/service as keycard_service
import app_service/service/devices/service as devices_service
from app_service/service/settings/dto/settings import SettingsDto

import app/modules/shared_modules/keycard_popup/module as keycard_shared_module

export io_interface

logScope:
  topics = "startup-module"

const FetchingFromWakuProfile = "profile"
const FetchingFromWakuProfileIcon = "profile"
const FetchingFromWakuContacts = "contacts"
const FetchingFromWakuContactsIcon = "contact-book"
const FetchingFromWakuCommunities = "communities"
const FetchingFromWakuCommunitiesIcon = "communities"
const FetchingFromWakuSettings = "settings"
const FetchingFromWakuSettingsIcon = "settings"
const FetchingFromWakuKeypairs = "keypairs"
const FetchingFromWakuKeypairsIcon = "wallet"
const FetchingFromWakuWatchOnlyAccounts = "watchOnlyAccounts"
const FetchingFromWakuWatchOnlyAccountsIcon = "wallet"

const listOfEntitiesWeExpectToBeSynced = @[
    (FetchingFromWakuProfile, FetchingFromWakuProfileIcon),
    (FetchingFromWakuContacts, FetchingFromWakuContactsIcon),
    (FetchingFromWakuCommunities, FetchingFromWakuCommunitiesIcon),
    (FetchingFromWakuSettings, FetchingFromWakuSettingsIcon),
    (FetchingFromWakuKeypairs, FetchingFromWakuKeypairsIcon),
    (FetchingFromWakuWatchOnlyAccounts, FetchingFromWakuWatchOnlyAccountsIcon)
  ]

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
    devicesService: devices_service.Service
    keycardSharedModule: keycard_shared_module.AccessInterface

proc newModule*[T](delegate: T,
  events: EventEmitter,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  generalService: general_service.Service,
  profileService: profile_service.Service,
  keycardService: keycard_service.Service,
  devicesService: devices_service.Service):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService
  result.keychainService = keychainService
  result.devicesService = devicesService
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, generalService, accountsService, keychainService,
  profileService, keycardService, devicesService)

{.push warning[Deprecated]: off.}

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete

method onAppLoaded*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("startupModule", newQVariant())
  self.view.delete
  self.view = nil
  self.viewVariant.delete
  self.viewVariant = nil
  self.controller.delete
  self.controller = nil
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete
    self.keycardSharedModule = nil

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

  if self.controller.shouldStartWithOnboardingScreen():
    self.view.setCurrentStartupState(newWelcomeState(state.FlowType.General, nil))
  else:
    let openedAccounts = self.controller.getOpenedAccounts()
    var items: seq[login_acc_item.Item]
    for i in 0..<openedAccounts.len:
      let acc = openedAccounts[i]
      var thumbnailImage: string
      var largeImage: string
      self.extractImages(acc, thumbnailImage, largeImage)
      items.add(login_acc_item.initItem(order = i, acc.name, icon = "", thumbnailImage, largeImage, acc.keyUid, acc.colorHash,
        acc.colorId, acc.keycardPairing))
    # set the first account as slected one
    if items.len == 0:
      # we should never be here, since else block of `if (shouldStartWithOnboardingScreen)`
      # ensures that `openedAccounts` is not empty array
      error "cannot run the app in login flow cause list of login accounts is empty"
      quit() # quit the app
    items.add(login_acc_item.initItem(order = items.len, name = atc.LOGIN_ACCOUNTS_LIST_ADD_NEW_USER, icon = "add",
      thumbnailImage = "", largeImage = "", keyUid = ""))
    items.add(login_acc_item.initItem(order = items.len, name = atc.LOGIN_ACCOUNTS_LIST_ADD_EXISTING_USER, icon = "wallet",
      thumbnailImage = "", largeImage = "", keyUid = ""))
    items.add(login_acc_item.initItem(order = items.len, name = atc.LOGIN_ACCOUNTS_LIST_LOST_KEYCARD, icon = "keycard",
      thumbnailImage = "", largeImage = "", keyUid = ""))
    self.view.setLoginAccountsModelItems(items)
    self.setSelectedLoginAccount(items[0])
  self.delegate.startupDidLoad()

proc isSharedKeycardModuleFlowRunning[T](self: Module[T]): bool =
  return not self.keycardSharedModule.isNil

method getKeycardSharedModule*[T](self: Module[T]): QVariant =
  if self.isSharedKeycardModuleFlowRunning():
    return self.keycardSharedModule.getModuleAsVariant()

proc createSharedKeycardModule[T](self: Module[T]) =
  self.keycardSharedModule = keycard_shared_module.newModule[Module[T]](self, UNIQUE_STARTUP_MODULE_IDENTIFIER,
    self.events, self.keycardService, settingsService = nil, networkService = nil, privacyService = nil, self.accountsService,
    walletAccountService = nil, self.keychainService)

method moveToLoadingAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.AppLoadingState)

method moveToAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.MainAppState)

method moveToStartupState*[T](self: Module[T]) =
  self.view.setAppState(AppState.StartupState)

proc moveToAppEncryptionProcessState[T](self: Module[T]) =
  self.view.setAppState(AppState.AppEncryptionProcessState)

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
  if backState.isNil:
    return
  self.view.setCurrentStartupState(backState)
  debug "back_action - set state", setCurrFlow=backState.flowType(), newCurrState=backState.stateType()

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

method onQuaternaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "quaternary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeQuaternaryCommand(self.controller)
  let nextState = currStateObj.getNextQuaternaryState(self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "quaternary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

method onQuinaryActionClicked*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state"
    return
  debug "quinary_action", currFlow=currStateObj.flowType(), currState=currStateObj.stateType()
  currStateObj.executeQuinaryCommand(self.controller)
  let nextState = currStateObj.getNextQuinaryState(self.controller)
  if nextState.isNil:
    return
  self.view.setCurrentStartupState(nextState)
  debug "quinary_action - set state", setCurrFlow=nextState.flowType(), setCurrState=nextState.stateType()

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

method emitStartupError*[T](self: Module[T], error: string, errType: StartupErrorType) =
  self.view.emitStartupError(error, errType)

method validMnemonic*[T](self: Module[T], mnemonic: string): bool =
  return self.controller.validMnemonic(mnemonic)

method setSelectedLoginAccount*[T](self: Module[T], item: login_acc_item.Item) =
  self.controller.cancelCurrentFlow()
  if item.getKeyUid().len == 0:
    error "all accounts must have non empty key uid"
    return
  self.controller.setSelectedLoginAccount(item.getKeyUid(), item.getKeycardCreatedAccount())
  if item.getKeycardCreatedAccount():
    self.view.setCurrentStartupState(newLoginState(state.FlowType.AppLogin, nil))
    self.controller.runLoginFlow()
  else:
    let value = singletonInstance.localAccountSettings.getStoreToKeychainValue()
    if value == LS_VALUE_STORE:
      self.view.setCurrentStartupState(newLoginState(state.FlowType.AppLogin, nil))
      self.controller.tryToObtainDataFromKeychain()
    else:
      self.view.setCurrentStartupState(newLoginKeycardEnterPasswordState(state.FlowType.AppLogin, nil))
  self.view.setSelectedLoginAccount(item)

method emitAccountLoginError*[T](self: Module[T], error: string) =
  self.controller.setPassword("")
  self.view.emitAccountLoginError(error)

method emitObtainingPasswordError*[T](self: Module[T], errorDescription: string, errorType: string) =
  self.view.emitObtainingPasswordError(errorDescription, errorType)

method emitObtainingPasswordSuccess*[T](self: Module[T], password: string) =
  self.view.emitObtainingPasswordSuccess(password)

method finishAppLoading*[T](self: Module[T]) =
  self.delegate.appReady()
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil:
    var eventType = "user-logged-in"
    if currStateObj.flowType() != FlowType.AppLogin:
      eventType = "onboarding-completed"
    singletonInstance.globalEvents.addCentralizedMetricIfEnabled(eventType,
      $(%*{"flowType": currStateObj.flowType()}))

  self.delegate.finishAppLoading()


method checkFetchingStatusAndProceed*[T](self: Module[T]) =
  if self.view.fetchingDataModel().isEntityLoaded(FetchingFromWakuProfile):
    if self.view.getLocalPairingInstallationId() != "":
      self.controller.finishPairingThroughSeedPhraseProcess(self.view.getLocalPairingInstallationId())
    self.finishAppLoading()
    return
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state in order to resolve next state"
    return
  let nextState = newProfileFetchingAnnouncementState(currStateObj.flowType(), nil)
  self.view.setCurrentStartupState(nextState)

method onFetchingFromWakuMessageReceived*[T](self: Module[T], backedUpMsgClock: uint64, section: string,
  totalMessages: int, receivedMessageAtPosition: int) =
  if not self.view.fetchingDataModel().evaluateWhetherToProcessReceivedData(backedUpMsgClock, listOfEntitiesWeExpectToBeSynced):
    return
  if self.view.fetchingDataModel().allMessagesLoaded():
    return
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot resolve current state for fetching data model update"
    return
  if currStateObj.flowType() != state.FlowType.FirstRunOldUserImportSeedPhrase and
    currStateObj.flowType() != state.FlowType.FirstRunOldUserKeycardImport:
      error "update fetching data model is out of context for the flow", flow=currStateObj.flowType()
      return
  if totalMessages > 0:
    self.view.fetchingDataModel().updateTotalMessages(section, totalMessages)
  else:
    self.view.fetchingDataModel().removeSection(section)
  if receivedMessageAtPosition > 0:
    self.view.fetchingDataModel().receivedMessageAtPosition(section, receivedMessageAtPosition)
  if self.view.fetchingDataModel().allMessagesLoaded():
    self.view.setCurrentStartupState(newProfileFetchingSuccessState(currStateObj.flowType(), nil))

method prepareAndInitFetchingData*[T](self: Module[T]) =
  # fetching data from waku starts when messenger starts
  self.view.createAndInitFetchingDataModel(listOfEntitiesWeExpectToBeSynced)

proc logoutAndDisplayError[T](self: Module[T], error: string, errType: StartupErrorType) =
  self.delegate.logout()
  if self.controller.isSelectedLoginAccountKeycardAccount() and
    errType == StartupErrorType.ConvertToRegularAccError:
      self.view.setCurrentStartupState(newLoginState(state.FlowType.AppLogin, nil))
      self.controller.runLoginFlow()
      self.moveToStartupState()
      self.emitStartupError(error, errType)
      return
  self.moveToStartupState()
  self.emitAccountLoginError(error)

method onProfileConverted*[T](self: Module[T], success: bool) =
  if not success:
    self.logoutAndDisplayError("", StartupErrorType.ConvertToRegularAccError)
    return
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot determine current startup state", procName="onProfileConverted"
    quit() # quit the app
  self.delegate.logout()
  self.moveToStartupState()
  self.view.setCurrentStartupState(newLoginKeycardConvertedToRegularAccountState(currStateObj.flowType(), nil))

method onNodeLogin*[T](self: Module[T], error: string, account: AccountDto, settings: SettingsDto) =
  let currStateObj = self.view.currentStartupStateObj()
  if currStateObj.isNil:
    error "cannot determine current startup state", procName="onNodeLogin"
    quit() # quit the app

  if error.len != 0:
    self.moveToStartupState()
    if currStateObj.flowType() == state.FlowType.AppLogin:
      if self.controller.isSelectedLoginAccountKeycardAccount():
        self.view.setCurrentStartupState(newLoginState(state.FlowType.AppLogin, nil))
        self.controller.runLoginFlow()
      self.emitAccountLoginError(error)
    else:
      self.emitStartupError(error, StartupErrorType.SetupAccError)
    error "login error", methodName="onNodeLogin", errDesription =error
    return

  self.controller.setLoggedInAccount(account)
  self.accountsService.updateLoggedInAccount(account.name, account.images)
  self.controller.setLoggedInProfile(settings.publicKey)
  self.view.notifyLoggedInAccountChanged()

  if currStateObj.flowType() == state.FlowType.FirstRunOldUserImportSeedPhrase or
    currStateObj.flowType() == state.FlowType.FirstRunOldUserKeycardImport:
    let err = self.delegate.userLoggedIn()
    if err.len > 0:
      self.logoutAndDisplayError(err, StartupErrorType.UnknownType)
      return
    return

  if currStateObj.flowType() == state.FlowType.LostKeycardConvertToRegularAccount:
    self.controller.convertKeycardProfileKeypairToRegular()
    return

  let err = self.delegate.userLoggedIn()
  if err.len > 0:
    self.logoutAndDisplayError(err, StartupErrorType.UnknownType)
    return

  if currStateObj.flowType() == FlowType.AppLogin:
    self.finishAppLoading()
    return

  # TODO: Remove this block when implemented https://github.com/status-im/status-go/issues/4977
  if currStateObj.flowType() == FlowType.FirstRunNewUserNewKeycardKeys or
    currStateObj.flowType() == FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard:
    let images = self.controller.storeIdentityImage()
    self.accountsService.updateLoggedInAccount(self.getDisplayName, images)
    self.view.notifyLoggedInAccountChanged()

  var nextState: state.State
  if currStateObj.flowType() == FlowType.LostKeycardReplacement:
    if not self.controller.notificationsNeedsEnable():
      self.finishAppLoading()
      return
    nextState = newNotificationState(currStateObj.flowType(), nil)
  else:
    nextState = newUserProfileChatKeyState(currStateObj.flowType(), nil)
  self.view.setCurrentStartupState(nextState)
  self.moveToStartupState()

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

method getKeycardData*[T](self: Module[T]): string =
  return self.view.getKeycardData()

method setKeycardData*[T](self: Module[T], value: string) =
  self.view.setKeycardData(value)

method setRemainingAttempts*[T](self: Module[T], value: int) =
  self.view.setRemainingAttempts(value)

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
      let currStateObj = self.view.currentStartupStateObj()
      if currStateObj.isNil:
        error "cannot resolve current state for onboarding/login flow continuation"
        return
      if currStateObj.flowType() == state.FlowType.FirstRunNewUserNewKeycardKeys or
        currStateObj.flowType() == state.FlowType.FirstRunNewUserImportSeedPhraseIntoKeycard or
        currStateObj.flowType() == state.FlowType.LostKeycardReplacement:
          let newState = currStateObj.getBackState()
          if newState.isNil:
            error "cannot resolve new state for onboarding/login flow continuation after shared flow is terminated"
            return
          self.view.setCurrentStartupState(newState)
          debug "new state for onboarding/login flow continuation after shared flow is terminated", setCurrFlow=newState.flowType(), newCurrState=newState.stateType()

method syncKeycardBasedOnAppWalletStateAfterLogin*[T](self: Module[T]) =
  self.delegate.syncKeycardBasedOnAppWalletStateAfterLogin()

method applyKeycardReplacementAfterLogin*[T](self: Module[T]) =
  self.delegate.applyKeycardReplacementAfterLogin()

method addToKeycardUidPairsToCheckForAChangeAfterLogin*[T](self: Module[T], oldKeycardUid: string, newKeycardUid: string) =
  self.delegate.addToKeycardUidPairsToCheckForAChangeAfterLogin(oldKeycardUid, newKeycardUid)

method removeAllKeycardUidPairsForCheckingForAChangeAfterLogin*[T](self: Module[T]) =
  self.delegate.removeAllKeycardUidPairsForCheckingForAChangeAfterLogin()
  if self.view.getLocalPairingInstallationId() != "":
    self.controller.finishPairingThroughSeedPhraseProcess(self.view.getLocalPairingInstallationId())

method getConnectionString*[T](self: Module[T]): string =
  return self.controller.getConnectionString()

method setConnectionString*[T](self: Module[T], connectionString: string) =
  self.controller.setConnectionString(connectionString)

method validateLocalPairingConnectionString*[T](self: Module[T], connectionString: string): string =
  return self.controller.validateLocalPairingConnectionString(connectionString)

method onLocalPairingStatusUpdate*[T](self: Module[T], status: LocalPairingStatus) =
  self.view.onLocalPairingStatusUpdate(status)

method onReencryptionProcessStarted*[T](self: Module[T]) =
  self.moveToAppEncryptionProcessState()

method onReencryptionProcessFinished*[T](self: Module[T]) =
  let currStateObj = self.view.currentStartupStateObj()
  if not currStateObj.isNil and
    currStateObj.flowType() == FlowType.LostKeycardConvertToRegularAccount and
    currStateObj.stateType() == StateType.LoginKeycardConvertedToRegularAccount:
      self.moveToStartupState()
      return
  self.moveToLoadingAppState()

## Used in test env only, for testing keycard flows
method registerMockedKeycard*[T](self: Module[T], cardIndex: int, readerState: int, keycardState: int,
  mockedKeycard: string, mockedKeycardHelper: string) =
  self.keycardService.registerMockedKeycard(cardIndex, readerState, keycardState, mockedKeycard, mockedKeycardHelper)

method pluginMockedReaderAction*[T](self: Module[T]) =
  self.keycardService.pluginMockedReaderAction()

method unplugMockedReaderAction*[T](self: Module[T]) =
  self.keycardService.unplugMockedReaderAction()

method insertMockedKeycardAction*[T](self: Module[T], cardIndex: int) =
  self.keycardService.insertMockedKeycardAction(cardIndex)

method removeMockedKeycardAction*[T](self: Module[T]) =
  self.keycardService.removeMockedKeycardAction()

method notificationsNeedsEnable*[T](self: Module[T]): bool = 
  return self.controller.notificationsNeedsEnable()

method getLoggedInAccountPublicKey*[T](self: Module[T]): string =
  return self.controller.getLoggedInAccountPublicKey()

method getLoggedInAccountDisplayName*[T](self: Module[T]): string =
  return self.controller.getLoggedInAccountDisplayName()

method getLoggedInAccountImage*[T](self: Module[T]): string =
  return self.controller.getLoggedInAccountImage()

method notifyLoggedInAccountChanged*[T](self: Module[T]) =
  self.view.notifyLoggedInAccountChanged()

{.pop.}
