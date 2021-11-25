import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/mnemonic/service as mnemonic_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, mnemonicService: mnemonic_service.ServiceInterface): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, mnemonicService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("mnemonicModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.mnemonicModuleDidLoad()

method isBackedUp*(self: Module): bool =
  return self.controller.isBackedup()

method getMnemonic*(self: Module): string =
  return self.controller.getMnemonic()

method remove*(self: Module) =
  self.controller.remove()

method getWord*(self: Module, index: int): string =
  return self.controller.getWord(index)
