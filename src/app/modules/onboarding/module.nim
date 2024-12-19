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

{.pop.}
