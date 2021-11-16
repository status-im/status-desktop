import NimQml
import io_interface
import ../io_interface as delegate_interface
import view
import sets
import controller
import ../../../../global/global_singleton
import ../../../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import options
export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    controller: controller.AccessInterface

proc newModule*(delegate: delegate_interface.AccessInterface, dappPermissionsService: dapp_permissions_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.moduleLoaded = false
  result.controller = controller.newController(result, dappPermissionsService)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method fetchDapps*(self: Module) =
  self.view.clearDapps()
  let dapps = self.controller.getDapps()
  for d in dapps:
    self.view.addDapp(d.name)

method fetchPermissions(self: Module, dapp: string) =
  self.view.clearPermissions()
  let dapp = self.controller.getDapp(dapp)
  if dapp.isSome:
    for p in dapp.get().permissions.items:
      self.view.addPermission($p)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("dappPermissionsModule", self.viewVariant)
  self.view.load()
  self.fetchDapps()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  self.moduleLoaded = true
  self.delegate.dappsDidLoad()

method dappsDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method hasPermission*(self: Module, hostname: string, permission: string): bool =
  self.controller.hasPermission(hostname, permission.toPermission())

method addPermission*(self: Module, hostname: string, permission: string) =
  self.controller.addPermission(hostname, permission.toPermission())

method clearPermissions*(self: Module, dapp: string) =
  self.controller.clearPermissions(dapp)

method revokeAllPermissions*(self: Module) =
  self.controller.revokeAllPermisions()

method revokePermission*(self: Module, dapp: string, name: string) =
  self.controller.revokePermission(dapp, name)
