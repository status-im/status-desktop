import NimQml
import io_interface
import ../io_interface as delegate_interface
import view
import ../../../global/global_singleton
import provider/module as provider_module
import bookmark/module as bookmark_module
import dapps/module as dapps_module
import ../../../../app_service/service/bookmarks/service as bookmark_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../app_service/service/provider/service as provider_service
export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    providerModule: provider_module.AccessInterface
    bookmarkModule: bookmark_module.AccessInterface
    dappsModule: dapps_module.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface,
    bookmarkService: bookmark_service.ServiceInterface,
    settingsService: settings_service.ServiceInterface,
    dappPermissionsService: dapp_permissions_service.ServiceInterface,
    providerService: provider_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.providerModule = provider_module.newModule(result, settingsService, dappPermissionsService, providerService)
  result.bookmarkModule = bookmark_module.newModule(result, bookmarkService)
  result.dappsModule = dapps_module.newModule(result, dappPermissionsService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.providerModule.delete
  self.bookmarkModule.delete
  self.dappsModule.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSection", self.viewVariant)
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
