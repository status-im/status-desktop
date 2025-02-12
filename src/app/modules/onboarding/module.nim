import NimQml, chronicles, json, strutils
import logging

import io_interface
import view, controller

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/accounts/service as accounts_service
import app_service/service/devices/service as devices_service
import app_service/service/keycardV2/service as keycard_serviceV2
from app_service/service/settings/dto/settings import SettingsDto
from app_service/service/accounts/dto/accounts import AccountDto
from app_service/service/keycardV2/dto import KeycardEventDto, KeycardExportedKeysDto, KeycardState
import app/modules/onboarding/post_onboarding/[keycard_replacement_task]

import ../startup/models/login_account_item as login_acc_item

export io_interface

logScope:
  topics = "onboarding-module"

# NOTE: Keep in sync with OnboardingFlow in ui/StatusQ/src/onboarding/enums.h
type OnboardingFlow* {.pure} = enum
  Unknown = 0,

  CreateProfileWithPassword,
  CreateProfileWithSeedphrase,
  CreateProfileWithKeycardNewSeedphrase,
  CreateProfileWithKeycardExistingSeedphrase,
  
  LoginWithSeedphrase,
  LoginWithSyncing,
  LoginWithKeycard,

  LoginWithLostKeycardSeedphrase,
  LoginWithRestoredKeycard

type LoginMethod* {.pure} = enum
  Unknown = 0,
  Password,
  Keycard,

type ProgressState* {.pure.} = enum
  Idle,
  InProgress,
  Success,
  Failed,

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    localPairingStatus: LocalPairingStatus
    loginFlow: LoginMethod
    onboardingFlow: OnboardingFlow
    exportedKeys: KeycardExportedKeysDto
    postOnboardingTasks: seq[PostOnboardingTask]

proc newModule*[T](
    delegate: T,
    events: EventEmitter,
    generalService: general_service.Service,
    accountsService: accounts_service.Service,
    devicesService: devices_service.Service,
    keycardServiceV2: keycard_serviceV2.Service,
  ): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.onboardingFlow = OnboardingFlow.Unknown
  result.loginFlow = LoginMethod.Unknown
  result.postOnboardingTasks = newSeq[PostOnboardingTask]()
  result.controller = controller.newController(
    result,
    events,
    generalService,
    accountsService,
    devicesService,
    keycardServiceV2,
  )

{.push warning[Deprecated]: off.}

method delete*[T](self: Module[T]) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method onAppLoaded*[T](self: Module[T]) =
  self.view.appLoaded()
  singletonInstance.engine.setRootContextProperty("onboardingModule", newQVariant())
  self.view.delete
  self.view = nil
  self.viewVariant.delete
  self.viewVariant = nil
  self.controller.delete
  self.controller = nil

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("onboardingModule", self.viewVariant)
  self.controller.init()

  let openedAccounts = self.controller.getOpenedAccounts()
  if openedAccounts.len > 0:
    var items: seq[login_acc_item.Item]
    for i in 0..<openedAccounts.len:
      let acc = openedAccounts[i]
      var thumbnailImage: string
      var largeImage: string
      acc.extractImages(thumbnailImage, largeImage)
      items.add(login_acc_item.initItem(order = i, acc.name, icon = "", thumbnailImage, largeImage, acc.keyUid, acc.colorHash,
        acc.colorId, acc.keycardPairing))

    self.view.setLoginAccountsModelItems(items)

  self.delegate.onboardingDidLoad()

method initialize*[T](self: Module[T], pin: string) =
  self.view.setPinSettingState(ProgressState.InProgress.int)
  self.controller.initialize(pin)

method authorize*[T](self: Module[T], pin: string) =
  self.view.setAuthorizationState(ProgressState.InProgress.int)
  self.controller.authorize(pin)

method getPasswordStrengthScore*[T](self: Module[T], password, userName: string): int =
  self.controller.getPasswordStrengthScore(password, userName)

method validMnemonic*[T](self: Module[T], mnemonic: string): bool =
  self.controller.validMnemonic(mnemonic)

method generateMnemonic*[T](self: Module[T]): string =
  return self.controller.generateMnemonic(SupportedMnemonicLength12)

method validateLocalPairingConnectionString*[T](self: Module[T], connectionString: string): bool =
  self.controller.validateLocalPairingConnectionString(connectionString)

method inputConnectionStringForBootstrapping*[T](self: Module[T], connectionString: string) =
  self.controller.inputConnectionStringForBootstrapping(connectionString)

method loadMnemonic*[T](self: Module[T], mnemonic: string) =
  self.view.setAddKeyPairState(ProgressState.InProgress.int)
  self.controller.loadMnemonic(mnemonic)

method finishOnboardingFlow*[T](self: Module[T], flowInt: int, dataJson: string): string =
  debug "finishOnboardingFlow", flowInt, dataJson
  self.postOnboardingTasks = newSeq[PostOnboardingTask]()

  try:
    self.onboardingFlow = OnboardingFlow(flowInt)

    let data = parseJson(dataJson)
    let password = data["password"].str
    let seedPhrase = data["seedphrase"].str

    var err = ""

    case self.onboardingFlow:
      # CREATE PROFILE FLOWS
      of OnboardingFlow.CreateProfileWithPassword:
        err = self.controller.createAccountAndLogin(password)
      of OnboardingFlow.CreateProfileWithSeedphrase:
        err = self.controller.restoreAccountAndLogin(
          password,
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = "",
        )
      of OnboardingFlow.CreateProfileWithKeycardNewSeedphrase:
        # New user with a seedphrase we showed them
        let keycardEvent = self.view.getKeycardEvent()
        err = self.controller.restoreAccountAndLogin(
          password = "", # For keycard it will be substituted with `encryption.publicKey` in status-go
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = keycardEvent.keycardInfo.instanceUID,
        )
      of OnboardingFlow.CreateProfileWithKeycardExistingSeedphrase:
        # New user who entered their own seed phrase
        let keycardEvent = self.view.getKeycardEvent()
        err = self.controller.restoreAccountAndLogin(
          password = "", # For keycard it will be substituted with `encryption.publicKey` in status-go
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = keycardEvent.keycardInfo.instanceUID,
        )
      
      # LOGIN FLOWS
      of OnboardingFlow.LoginWithSeedphrase:
        err = self.controller.restoreAccountAndLogin(
          password,
          seedPhrase,
          recoverAccount = true,
          keycardInstanceUID = "",
        )        
      of OnboardingFlow.LoginWithSyncing:
        # The pairing was already done directly through inputConnectionStringForBootstrapping, we can login
        self.controller.loginLocalPairingAccount(
          self.localPairingStatus.account,
          self.localPairingStatus.password,
          self.localPairingStatus.chatKey,
        )
      of OnboardingFlow.LoginWithKeycard:
        err = self.controller.restoreKeycardAccountAndLogin(
          self.view.getKeycardEvent().keycardInfo.keyUID,
          self.view.getKeycardEvent().keycardInfo.instanceUID,
          self.exportedKeys,
          recoverAccount = true
          )
      else:
        raise newException(ValueError, "Unknown onboarding flow: " & $self.onboardingFlow)

    return err
  except Exception as e:
    error "Error finishing Onboarding Flow", msg = e.msg
    return e.msg

method loginRequested*[T](self: Module[T], keyUid: string, loginFlow: int, dataJson: string) =
  try:
    self.loginFlow = LoginMethod(loginFlow)

    let data = parseJson(dataJson)
    let account = self.controller.getAccountByKeyUid(keyUid)

    case self.loginFlow:
      of LoginMethod.Password:
        self.controller.login(account, data["password"].str)
      of LoginMethod.Keycard:
        self.authorize(data["pin"].str)
        # We will continue the flow when the card is authorized in onKeycardStateUpdated
      else:
        raise newException(ValueError, "Unknown login flow: " & $self.loginFlow)

  except Exception as e:
    error "Error finishing Login Flow", msg = e.msg
    self.view.accountLoginError(e.msg, wrongPassword = false)

proc finishAppLoading2[T](self: Module[T]) =
  self.delegate.appReady()

  var eventType = "user-logged-in"
  if self.loginFlow == LoginMethod.Unknown:
    eventType = "onboarding-completed"
  singletonInstance.globalEvents.addCentralizedMetricIfEnabled(eventType,
    $(%*{"flowType": repr(self.onboardingFlow)}))

  self.controller.stopKeycardService()

  self.delegate.finishAppLoading()

method onAccountLoginError*[T](self: Module[T], error: string) =
  # SQLITE_NOTADB: "file is not a database"
  var wrongPassword = false
  if error.contains("file is not a database"):
    wrongPassword = true
  self.view.accountLoginError(error, wrongPassword)
  
method onNodeLogin*[T](self: Module[T], err: string, account: AccountDto, settings: SettingsDto) =
  if err.len != 0:
    self.onAccountLoginError(err)
    return

  self.controller.setLoggedInAccount(account)

  let err2 = self.delegate.userLoggedIn()
  if err2.len != 0:
    error "error from userLoggedIn", err2
    return

  if self.localPairingStatus != nil and self.localPairingStatus.installation != nil and self.localPairingStatus.installation.id != "":
    # We tried to login by pairing, so finilize the process
    self.controller.finishPairingThroughSeedPhraseProcess(self.localPairingStatus.installation.id)
  
  self.finishAppLoading2()

method onLocalPairingStatusUpdate*[T](self: Module[T], status: LocalPairingStatus) =
  self.localPairingStatus = status
  self.view.setSyncState(status.state.int)

method onKeycardStateUpdated*[T](self: Module[T], keycardEvent: KeycardEventDto) =
  self.view.setKeycardEvent(keycardEvent)

  if keycardEvent.state == KeycardState.Authorized and self.loginFlow == LoginMethod.Keycard:
    # After authorizing, we export the keys
    self.controller.exportLoginKeysFromKeycard()
    # We will login once we have the keys in onKeycardExportLoginKeysSuccess

  if keycardEvent.state == KeycardState.NotEmpty and self.view.getPinSettingState() == ProgressState.InProgress.int:
    # We just finished setting the pin
    self.view.setPinSettingState(ProgressState.Success.int)

  if keycardEvent.state == KeycardState.Authorized and self.view.getAuthorizationState() == ProgressState.InProgress.int:
    # We just finished authorizing
    self.view.setAuthorizationState(ProgressState.Success.int)

method onKeycardSetPinFailure*[T](self: Module[T], error: string) =
  self.view.setPinSettingState(ProgressState.Failed.int)

method onKeycardAuthorizeFailure*[T](self: Module[T], error: string) =
  self.view.setAuthorizationState(ProgressState.Failed.int)

  if self.loginFlow == LoginMethod.Keycard:
    # We were trying to login and the authorization failed
    var wrongPassword = false
    if error.contains("wrong pin"):
      wrongPassword = true
    self.view.accountLoginError(error, wrongPassword)

method onKeycardLoadMnemonicFailure*[T](self: Module[T], error: string) =
  self.view.setAddKeyPairState(ProgressState.Failed.int)

method onKeycardLoadMnemonicSuccess*[T](self: Module[T], keyUID: string) =
  self.view.setAddKeyPairState(ProgressState.Success.int)

method onKeycardExportRestoreKeysFailure*[T](self: Module[T], error: string) =
  self.view.setRestoreKeysExportState(ProgressState.Failed.int)

method onKeycardExportRestoreKeysSuccess*[T](self: Module[T], exportedKeys: KeycardExportedKeysDto) =
  self.exportedKeys = exportedKeys
  self.view.setRestoreKeysExportState(ProgressState.Success.int)

method onKeycardExportLoginKeysFailure*[T](self: Module[T], error: string) =
  self.view.accountLoginError(error, wrongPassword = false)

method onKeycardExportLoginKeysSuccess*[T](self: Module[T], exportedKeys: KeycardExportedKeysDto) =
  let keycardInfo = self.view.getKeycardEvent().keycardInfo
  # We got the keys, now we can login. If everything goes well, we will finish the app loading
  let accountDto = self.controller.getAccountByKeyUid(keycardInfo.keyUID)
  self.controller.login(
    accountDto,
    password = "",
    keycard = true,
    publicEncryptionKey = exportedKeys.encryptionKey.publicKey,
    privateWhisperKey = exportedKeys.whisperKey.privateKey,
  )

method exportRecoverKeys*[T](self: Module[T]) =
  self.view.setRestoreKeysExportState(ProgressState.InProgress.int)
  self.controller.exportRecoverKeysFromKeycard()

method getPostOnboardingTasks*[T](self: Module[T]): seq[PostOnboardingTask] =
  return self.postOnboardingTasks

{.pop.}
