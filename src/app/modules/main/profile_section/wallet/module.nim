import NimQml
import ./io_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/network/service as network_service
import ../io_interface as delegate_interface

import ./networks/module as networks_module

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    moduleLoaded: bool

    networksModule: networks_module.AccessInterface
    

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.moduleLoaded = false

  result.networksModule = networks_module.newModule(result, events, networkService)
  
method delete*(self: Module) =
  self.networksModule.delete

method load*(self: Module) =
  self.networksModule.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  if(not self.networksModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.walletModuleDidLoad()

method networksModuleDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()
