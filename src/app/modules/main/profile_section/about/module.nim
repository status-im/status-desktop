import NimQml
import eventemitter

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

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    aboutService: about_service.Service
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, aboutService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("aboutModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.view.load()
  self.controller.init()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.aboutModuleDidLoad()

method getAppVersion*(self: Module): string =
  return self.controller.getAppVersion()

method getNodeVersion*(self: Module): string =
  return self.controller.getNodeVersion()

method checkForUpdates*(self: Module) =
  self.controller.checkForUpdates()

method versionFetched*(self: Module, version: string) =
  self.view.versionFetched(version)
