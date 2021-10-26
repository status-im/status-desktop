import NimQml
import io_interface
import view
import controller
import ../io_interface as delegate_interface
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../core/global_singleton
export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: controller.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface, settingsService: settings_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.controller = controller.newController(result, settingsService)

method delete*(self: Module) =
  self.controller.delete
  self.viewVariant.delete
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("providerModule", self.viewVariant)
  self.view.load()
  self.view.dappsAddress = self.controller.getDappsAddress()
  self.view.networkId = self.controller.getCurrentNetworkDetails().config.networkId

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method setDappsAddress*(self: Module, value: string) =
  self.controller.setDappsAddress(value)

method onDappAddressChanged*(self: Module, value: string) =
  self.view.dappsAddress = value

proc checkIfModuleDidLoad(self: Module) =
  self.moduleLoaded = true
  self.delegate.providerDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()
