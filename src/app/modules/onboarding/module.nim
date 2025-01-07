import NimQml, chronicles, json

import io_interface
import view, controller

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/accounts/service as accounts_service
import app_service/service/devices/service as devices_service
import app_service/service/keycardV2/service as keycard_serviceV2

export io_interface

logScope:
  topics = "onboarding-module"

type PrimaryFlow* {.pure} = enum
  Unknown = 0,
  CreateProfile,
  Login

type SecondaryFlow* {.pure} = enum
  Unknown = 0,
  CreateProfileWithPassword,
  CreateProfileWithSeedphrase,
  CreateProfileWithKeycard,
  CreateProfileWithKeycardNewSeedphrase,
  CreateProfileWithKeycardExistingSeedphrase,
  LoginWithSeedphrase,
  LoginWithSyncing,
  LoginWithKeycard

type
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller

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

method setPin*[T](self: Module[T], pin: string): bool =
  self.controller.setPin(pin)

method getPasswordStrengthScore*[T](self: Module[T], password, userName: string): int =
  self.controller.getPasswordStrengthScore(password, userName)

method validMnemonic*[T](self: Module[T], mnemonic: string): bool =
  self.controller.validMnemonic(mnemonic)

method getMnemonic*[T](self: Module[T]): string =
  self.controller.getMnemonic()

method validateLocalPairingConnectionString*[T](self: Module[T], connectionString: string): bool =
  self.controller.validateLocalPairingConnectionString(connectionString)

method inputConnectionStringForBootstrapping*[T](self: Module[T], connectionString: string) =
  self.controller.inputConnectionStringForBootstrapping(connectionString)

method finishOnboardingFlow*[T](self: Module[T], primaryFlowInt, secondaryFlowInt: int, dataJson: string): string =
  try:
    let primaryFlow = PrimaryFlow(primaryFlowInt)
    let secondaryFlow = SecondaryFlow(secondaryFlowInt)

    let data = parseJson(dataJson)
    let password = data["password"].str
    let seedPhrase = data["seedPhrase"].str

    var err = ""

    # CREATE PROFILE PRIMARY FLOW
    if primaryFlow == PrimaryFlow.CreateProfile:
      case secondaryFlow:
        of SecondaryFlow.CreateProfileWithPassword:
          err = self.controller.createAccountAndLogin(password)
        of SecondaryFlow.CreateProfileWithSeedphrase:
          err = self.controller.restoreAccountAndLogin(
            password,
            seedPhrase,
            recoverAccount = false,
            keycardInstanceUID = "",
          )
        of SecondaryFlow.CreateProfileWithKeycard:
          # TODO implement keycard function
          discard
        of SecondaryFlow.CreateProfileWithKeycardNewSeedphrase:
          # TODO implement keycard function
          discard
        of SecondaryFlow.CreateProfileWithKeycardExistingSeedphrase:
          # TODO implement keycard function
          discard
        else:
          raise newException(ValueError, "Unknown secondary flow for CreateProfile: " & $secondaryFlow)

    # LOGIN PRIMARY FLOW
    elif primaryFlow == PrimaryFlow.Login:
      case secondaryFlow:
        of SecondaryFlow.LoginWithSeedphrase:
          err = self.controller.restoreAccountAndLogin(
            password,
            seedPhrase,
            recoverAccount = true,
            keycardInstanceUID = "",
          )
        of SecondaryFlow.LoginWithSyncing:
          self.controller.inputConnectionStringForBootstrapping(data["connectionString"].str)
        of SecondaryFlow.LoginWithKeycard:
          # TODO implement keycard function
          discard
        else:
          raise newException(ValueError, "Unknown secondary flow for Login: " & $secondaryFlow)
      if err != "":
        raise newException(ValueError, err)
    else:
      raise newException(ValueError, "Unknown primary flow: " & $primaryFlow)
    
  except Exception as e:
    error "Error finishing Onboarding Flow", msg = e.msg
    return e.msg

{.pop.}
