import NimQml

import io_interface
import view, controller
import ../../../app/boot/global_singleton

import onboarding/module as onboarding_module
import login/module as login_module

import ../../../app_service/service/local_settings/service as local_settings_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter
import status/[fleet]

export io_interface

type 
  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    onboardingModule: onboarding_module.AccessInterface
    loginModule: login_module.AccessInterface

proc newModule*[T](delegate: T,
  events: EventEmitter,
  fleet: FleetModel,
  localSettingsService: local_settings_service.Service,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface): 
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, localSettingsService,
  keychainService, accountsService)

  # Submodules
  result.onboardingModule = onboarding_module.newModule(result, events, fleet, accountsService)
  result.loginModule = login_module.newModule(result, events, accountsService)
  
method delete*[T](self: Module[T]) =
  self.onboardingModule.delete
  self.loginModule.delete
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*[T](self: Module[T]) =
  singletonInstance.engine.setRootContextProperty("startupModule", self.viewVariant)
  self.controller.init()
  self.view.load()
  
  var initialAppState = AppState.OnboardingState
  if(not self.controller.shouldStartWithOnboardingScreen()):
    initialAppState = AppState.LoginState
  self.view.setAppState(initialAppState)
  
  self.onboardingModule.load()
  self.loginModule.load()

proc checkIfModuleDidLoad[T](self: Module[T]) =
  if(not self.onboardingModule.isLoaded()):
    return

  if(not self.loginModule.isLoaded()):
    return

  self.delegate.startupDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method onboardingDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method loginDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method userLoggedIn*[T](self: Module[T]) =
  self.delegate.userLoggedIn()

method moveToAppState*[T](self: Module[T]) =
  self.view.setAppState(AppState.MainAppState)