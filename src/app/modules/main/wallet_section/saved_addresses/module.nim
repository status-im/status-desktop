import NimQml, sugar, sequtils
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/saved_address/service as saved_address_service

import ./io_interface, ./view, ./controller, ./item

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    moduleLoaded: bool
    controller: Controller

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  savedAddressService: saved_address_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = newController(result, events, savedAddressService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

method loadSavedAddresses*(self: Module) =
  let savedAddresses = self.controller.getSavedAddresses()
  self.view.setItems(
    savedAddresses.map(s => initItem(
      s.name,
      s.address,
      s.favourite,
      s.ens,
      s.chainShortNames,
      s.isTest,
    ))
  )

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionSavedAddresses", newQVariant(self.view))

  self.loadSavedAddresses()
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.savedAddressesModuleDidLoad()

method createOrUpdateSavedAddress*(self: Module, name: string, address: string, favourite: bool, chainShortNames: string, ens: string) =
  self.controller.createOrUpdateSavedAddress(name, address, favourite, chainShortNames, ens)

method deleteSavedAddress*(self: Module, address: string, ens: string) =
  self.controller.deleteSavedAddress(address, ens)

method savedAddressUpdated*(self: Module, address: string, ens: string, errorMsg: string) =
  self.loadSavedAddresses()
  self.view.savedAddressUpdated(address, ens, errorMsg)

method savedAddressDeleted*(self: Module, address: string, ens: string, errorMsg: string) =
  self.loadSavedAddresses()
  self.view.savedAddressDeleted(address, ens, errorMsg)