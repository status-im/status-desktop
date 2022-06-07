import NimQml
import io_interface
import ../io_interface as delegate_interface
import view
import ../../../global/global_singleton
import ../../../core/eventemitter
import provider/module as provider_module
import bookmark/module as bookmark_module
import dapps/module as dapps_module
import current_account/module as current_account_module
import ../../../../app_service/service/bookmarks/service as bookmark_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../app_service/service/provider/service as provider_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    providerModule: provider_module.AccessInterface
    bookmarkModule: bookmark_module.AccessInterface
    dappsModule: dapps_module.AccessInterface
    currentAccountModule: current_account_module.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    bookmarkService: bookmark_service.Service,
    settingsService: settings_service.Service,
    networkService: network_service.Service,
    dappPermissionsService: dapp_permissions_service.Service,
    providerService: provider_service.Service,
    walletAccountService: wallet_account_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.providerModule = provider_module.newModule(result, events, settingsService, networkService, providerService)
  result.bookmarkModule = bookmark_module.newModule(result, events, bookmarkService)
  result.dappsModule = dapps_module.newModule(result, dappPermissionsService, walletAccountService)
  result.currentAccountModule = current_account_module.newModule(result, events, walletAccountService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.providerModule.delete
  self.bookmarkModule.delete
  self.dappsModule.delete
  self.currentAccountModule.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSection", self.viewVariant)
  self.currentAccountModule.load()
  self.providerModule.load()
  self.bookmarkModule.load()
  self.dappsModule.load()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.providerModule.isLoaded()):
    return

  if(not self.bookmarkModule.isLoaded()):
    return

  if(not self.dappsModule.isLoaded()):
    return

  if(not self.currentAccountModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.browserSectionDidLoad()

method providerDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method bookmarkDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method dappsDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method openUrl*(self: Module, url: string) =
  self.view.sendOpenUrlSignal(url)
