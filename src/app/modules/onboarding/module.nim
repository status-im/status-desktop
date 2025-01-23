import NimQml, chronicles, json
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

export io_interface

logScope:
  topics = "onboarding-module"

type SecondaryFlow* {.pure} = enum
  Unknown = 0,
  CreateProfileWithPassword,
  CreateProfileWithSeedphrase,
  CreateProfileWithKeycardNewSeedphrase,
  CreateProfileWithKeycardExistingSeedphrase,
  LoginWithSeedphrase,
  LoginWithSyncing,
  LoginWithKeycard,
  ActualLogin, # TODO get the real name and value for this when it's implemented on the front-end

type ProgressState* {.pure.} = enum
  Idle,
  InProgress,
  Success,
  Failed

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    localPairingStatus: LocalPairingStatus
    currentFlow: SecondaryFlow
    exportedKeys: KeycardExportedKeysDto

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

method getMnemonic*[T](self: Module[T]): string =
  return self.controller.generateMnemonic(SupportedMnemonicLength12)

method validateLocalPairingConnectionString*[T](self: Module[T], connectionString: string): bool =
  self.controller.validateLocalPairingConnectionString(connectionString)

method inputConnectionStringForBootstrapping*[T](self: Module[T], connectionString: string) =
  self.controller.inputConnectionStringForBootstrapping(connectionString)

method loadMnemonic*[T](self: Module[T], mnemonic: string) =
  self.view.setAddKeyPairState(ProgressState.InProgress.int)
  self.controller.loadMnemonic(mnemonic)

method finishOnboardingFlow*[T](self: Module[T], flowInt: int, dataJson: string): string =
  try:
    self.currentFlow = SecondaryFlow(flowInt)

    let data = parseJson(dataJson)
    let password = data["password"].str
    let seedPhrase = data["seedphrase"].str

    var err = ""

    case self.currentFlow:
      # CREATE PROFILE FLOWS
      of SecondaryFlow.CreateProfileWithPassword:
        err = self.controller.createAccountAndLogin(password)
      of SecondaryFlow.CreateProfileWithSeedphrase:
        err = self.controller.restoreAccountAndLogin(
          password,
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = "",
        )
      of SecondaryFlow.CreateProfileWithKeycardNewSeedphrase:
        # New user with a seedphrase we showed them
        let keycardEvent = self.view.getKeycardEvent()
        err = self.controller.restoreAccountAndLogin(
          password = "", # For keycard it will be substituted with`encryption.publicKey` in status-go
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = keycardEvent.keycardInfo.instanceUID,
        )
      of SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase:
        # New user who entered their own seed phrase
        let keycardEvent = self.view.getKeycardEvent()
        err = self.controller.restoreAccountAndLogin(
          password = "", # For keycard it will be substituted with`encryption.publicKey` in status-go
          seedPhrase,
          recoverAccount = false,
          keycardInstanceUID = keycardEvent.keycardInfo.instanceUID,
        )
      
      # LOGIN FLOWS
      of SecondaryFlow.LoginWithSeedphrase:
        err = self.controller.restoreAccountAndLogin(
          password,
          seedPhrase,
          recoverAccount = true,
          keycardInstanceUID = "",
        )        
      of SecondaryFlow.LoginWithSyncing:
        # The pairing was already done directly through inputConnectionStringForBootstrapping, we can login
        self.controller.loginLocalPairingAccount(
          self.localPairingStatus.account,
          self.localPairingStatus.password,
          self.localPairingStatus.chatKey,
        )
      of SecondaryFlow.LoginWithKeycard:
        err = self.controller.restoreKeycardAccountAndLogin(
          self.view.getKeycardEvent().keycardInfo.keyUID,
          self.view.getKeycardEvent().keycardInfo.instanceUID,
          self.exportedKeys,
          recoverAccount = true
          )
      else:
        raise newException(ValueError, "Unknown flow: " & $self.currentFlow)

    return err
  except Exception as e:
    error "Error finishing Onboarding Flow", msg = e.msg
    return e.msg

proc finishAppLoading2[T](self: Module[T]) =
  self.delegate.appReady()

  # TODO get the flow to send the right metric
  var eventType = "user-logged-in"
  if self.currentFlow != SecondaryFlow.ActualLogin:
    eventType = "onboarding-completed"
  singletonInstance.globalEvents.addCentralizedMetricIfEnabled(eventType,
    $(%*{"flowType": repr(self.currentFlow)}))

  self.controller.stopKeycardService()

  self.delegate.finishAppLoading()
  
method onNodeLogin*[T](self: Module[T], error: string, account: AccountDto, settings: SettingsDto) =
  if error.len != 0:
    # TODO: Handle error
    echo "ERROR from onNodeLogin: ", error
    return

  self.controller.setLoggedInAccount(account)

  if self.localPairingStatus != nil and self.localPairingStatus.installation != nil and self.localPairingStatus.installation.id != "":
    # We tried to login by pairing, so finilize the process
    self.controller.finishPairingThroughSeedPhraseProcess(self.localPairingStatus.installation.id)
  
  self.finishAppLoading2()

method onLocalPairingStatusUpdate*[T](self: Module[T], status: LocalPairingStatus) =
  self.localPairingStatus = status
  self.view.setSyncState(status.state.int)

method onKeycardStateUpdated*[T](self: Module[T], keycardEvent: KeycardEventDto) =
  self.view.setKeycardEvent(keycardEvent)

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

method onKeycardLoadMnemonicFailure*[T](self: Module[T], error: string) =
  self.view.setAddKeyPairState(ProgressState.Failed.int)

method onKeycardLoadMnemonicSuccess*[T](self: Module[T], keyUID: string) =
  self.view.setAddKeyPairState(ProgressState.Success.int)

method onKeycardExportKeysFailure*[T](self: Module[T], error: string) =
  self.view.setRestoreKeysExportState(ProgressState.Failed.int)

method onKeycardExportKeysSuccess*[T](self: Module[T], exportedKeys: KeycardExportedKeysDto) =
  self.exportedKeys = exportedKeys
  self.view.setRestoreKeysExportState(ProgressState.Success.int)

method exportRecoverKeys*[T](self: Module[T]) =
  self.view.setRestoreKeysExportState(ProgressState.InProgress.int)
  self.controller.exportRecoverKeysFromKeycard()

{.pop.}
