import NimQml, chronicles

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface

import ../../../../core/eventemitter

import ../../../../../app_service/service/keycard/service as keycard_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/privacy/service as privacy_service
import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/keychain/service as keychain_service

import ../../../shared_modules/keycard_popup/module as keycard_shared_module

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    events: EventEmitter
    keycardService: keycard_service.Service
    settingsService: settings_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keychainService: keychain_service.Service
    keycardSharedModule: keycard_shared_module.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  settingsService: settings_service.Service,
  privacyService: privacy_service.Service,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  keychainService: keychain_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.settingsService = settingsService
  result.privacyService = privacyService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.keychainService = keychainService
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getKeycardSharedModule*(self: Module): QVariant =
  return self.keycardSharedModule.getModuleAsVariant()

proc createSharedKeycardModule(self: Module) =
  self.keycardSharedModule = keycard_shared_module.newModule[Module](self, UNIQUE_SETTING_KEYCARD_MODULE_IDENTIFIER, 
    self.events, self.keycardService, self.settingsService, self.privacyService, self.accountsService, 
    self.walletAccountService, self.keychainService)

proc isSharedKeycardModuleFlowRunning(self: Module): bool =
  return not self.keycardSharedModule.isNil

method onSharedKeycarModuleFlowTerminated*(self: Module, lastStepInTheCurrentFlow: bool) =
  if self.isSharedKeycardModuleFlowRunning():
    self.view.emitDestroyKeycardSharedModuleFlow()
    self.keycardSharedModule.delete
    self.keycardSharedModule = nil

method runSetupKeycardPopup*(self: Module) =
  self.createSharedKeycardModule()
  if self.keycardSharedModule.isNil:
    return
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.SetupNewKeycard)

method onDisplayKeycardSharedModuleFlow*(self: Module) =
  self.view.emitDisplayKeycardSharedModuleFlow()