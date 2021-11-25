import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/accounts/service as accounts_service
import ../../../../../app_service/service/privacy/service as privacy_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, privacyService: privacy_service.ServiceInterface, accountsService: accounts_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, privacyService, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("privacyModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.privacyModuleDidLoad()

method getLinkPreviewWhitelist*(self: Module): string =
  return self.controller.getLinkPreviewWhitelist()

method changePassword*(self: Module, password: string, newPassword: string): bool =
  return self.controller.changePassword(password, newPassword)
