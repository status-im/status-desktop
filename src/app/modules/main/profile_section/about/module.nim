import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/about/service as about_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, aboutService: about_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, aboutService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("aboutModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.aboutModuleDidLoad()

method getAppVersion*(self: Module): string =
  return self.controller.getAppVersion()

method getNodeVersion*(self: Module): string =
  return self.controller.getNodeVersion()
