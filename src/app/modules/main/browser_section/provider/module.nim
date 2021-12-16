import NimQml
import io_interface
import view
import controller
import ../io_interface as delegate_interface
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../../../app_service/service/provider/service as provider_service
import ../../../../core/global_singleton
export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: controller.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface,
  settingsService: settings_service.ServiceInterface,
  dappPermissionsService: dapp_permissions_service.ServiceInterface,
  providerService: provider_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.controller = controller.newController(result, settingsService, dappPermissionsService, providerService)

method delete*(self: Module) =
  self.controller.delete
  self.viewVariant.delete
  self.view.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("providerModule", self.viewVariant)
  self.view.dappsAddress = self.controller.getDappsAddress()
  self.view.networkId = self.controller.getCurrentNetworkDetails().config.networkId
  self.view.load()

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

method disconnect*(self: Module) =
  self.controller.disconnect()

method postMessage*(self: Module, requestType: string, message: string): string =
  return self.controller.postMessage(requestType, message)

method hasPermission*(self: Module, hostname: string, permission: string): bool =
  return self.controller.hasPermission(hostname, permission)

method ensResourceURL*(self: Module, ens: string, url: string): (string, string, string, string, bool) =
  return self.controller.ensResourceURL(ens, url)
