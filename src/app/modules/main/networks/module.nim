import NimQml
import ../io_interface as delegate_interface
import io_interface, view, controller
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  networkService: networkService.Service,
  walletAccountService: wallet_account_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, networkService, walletAccountService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("networksModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method refreshNetworks*(self: Module) =
  let networks = self.controller.getNetworks()
  self.view.load(networks)

method load*(self: Module) =
  self.controller.init()
  self.refreshNetworks()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc checkIfModuleDidLoad(self: Module) =
  self.moduleLoaded = true
  self.delegate.networksModuleDidLoad()

method viewDidLoad*(self: Module) =
  self.checkIfModuleDidLoad()

method toggleNetwork*(self: Module, chainId: int) =
  self.controller.toggleNetwork(chainId)