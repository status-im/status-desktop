import NimQml, chronicles

import ./io_interface as io_interface
import ./controller, ./view
import ../io_interface as delegate_interface

import ./accounts/module as accounts_module
import ./networks/module as networks_module

import app/global/global_singleton
import app/core/eventemitter
import app/modules/shared_modules/keypair_import/module as keypair_import_module
import app_service/service/accounts/service as accounts_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/settings/service as settings_service
import app_service/service/devices/service as devices_service

logScope:
  topics = "profile-section-wallet-module"

import io_interface
export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    events: EventEmitter
    moduleLoaded: bool
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    devicesService: devices_service.Service
    accountsModule: accounts_module.AccessInterface
    networksModule: networks_module.AccessInterface
    keypairImportModule: keypair_import_module.AccessInterface

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.Service,
  walletAccountService: wallet_account_service.Service,
  settingsService: settings_service.Service,
  networkService: network_service.Service,
  devicesService: devices_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.controller = controller.newController(result, events, walletAccountService)
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.events = events
  result.moduleLoaded = false
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.devicesService = devicesService
  result.accountsModule = accounts_module.newModule(result, events, walletAccountService, networkService)
  result.networksModule = networks_module.newModule(result, events, networkService, walletAccountService, settingsService)

method delete*(self: Module) =
  self.controller.delete
  self.view.delete
  self.viewVariant.delete
  self.accountsModule.delete
  self.networksModule.delete
  if not self.keypairImportModule.isNil:
    self.keypairImportModule.delete

method load*(self: Module) =
  self.controller.init()
  self.accountsModule.load()
  self.networksModule.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getCollectiblesModel*(self: Module): QVariant =
  return self.accountsModule.getCollectiblesModel()

proc checkIfModuleDidLoad(self: Module) =
  if(not self.accountsModule.isLoaded()):
    return

  if(not self.networksModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.walletModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method accountsModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method getAccountsModule*(self: Module): QVariant =
  return self.accountsModule.getModuleAsVariant()

method networksModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method getNetworksModule*(self: Module): QVariant =
  return self.networksModule.getModuleAsVariant()

method destroyKeypairImportPopup*(self: Module) =
  if self.keypairImportModule.isNil:
    return
  self.view.emitDestroyKeypairImportPopup()
  self.keypairImportModule.delete
  self.keypairImportModule = nil

method runKeypairImportPopup*(self: Module, keyUid: string, mode: ImportKeypairModuleMode) =
  self.keypairImportModule = keypair_import_module.newModule(self, self.events, self.accountsService,
    self.walletAccountService, self.devicesService)
  self.keypairImportModule.load(keyUid, mode)

method getKeypairImportModule*(self: Module): QVariant =
  if self.keypairImportModule.isNil:
    return newQVariant()
  return self.keypairImportModule.getModuleAsVariant()

method onKeypairImportModuleLoaded*(self: Module) =
  self.view.emitDisplayKeypairImportPopup()

method hasPairedDevices*(self: Module): bool =
  return self.controller.hasPairedDevices()

method onLocalPairingStatusUpdate*(self: Module, data: LocalPairingStatus) =
  if data.state == LocalPairingState.Finished:
    self.view.emitHasPairedDevicesChangedSignal()