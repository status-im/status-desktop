import NimQml
import io_interface
import ../io_interface as delegate_interface
import view
import ../../../core/global_singleton
import provider/module as provider_module
import bookmark/module as bookmark_module
import ../../../../app_service/service/bookmarks/service as bookmark_service
import ../../../../app_service/service/settings/service as settings_service
export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    providerModule: provider_module.AccessInterface
    bookmarkModule: bookmark_module.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface, bookmarkService: bookmark_service.ServiceInterface, settingsService: settings_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.providerModule = provider_module.newModule(result, settingsService)
  result.bookmarkModule = bookmark_module.newModule(result, bookmarkService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.providerModule.delete
  self.bookmarkModule.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("browserSection", self.viewVariant)
  self.providerModule.load()
  self.bookmarkModule.load()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.providerModule.isLoaded()):
    return

  if(not self.bookmarkModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.browserSectionDidLoad()

method providerDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method bookmarkDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

