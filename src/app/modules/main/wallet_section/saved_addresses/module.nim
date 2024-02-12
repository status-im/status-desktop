import NimQml, json, sugar, sequtils
import ../io_interface as delegate_interface

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/saved_address/service as saved_address_service

import io_interface, view, controller, model

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
      s.ens,
      s.colorId,
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

method createOrUpdateSavedAddress*(self: Module, name: string, address: string, ens: string, colorId: string,
  chainShortNames: string) =
  self.controller.createOrUpdateSavedAddress(name, address, ens, colorId, chainShortNames)

method updatePreferredChains*(self: Module, address: string, chainShortNames: string) =
  let item = self.view.getModel().getItemByAddress(address, self.controller.areTestNetworksEnabled())
  if item.getAddress().len == 0:
    return
  self.controller.createOrUpdateSavedAddress(item.getName(), address, item.getEns(), item.getColorId(), chainShortNames)

method deleteSavedAddress*(self: Module, address: string) =
  self.controller.deleteSavedAddress(address)

method savedAddressUpdated*(self: Module, name: string, address: string, isTestAddress: bool, errorMsg: string) =
  if isTestAddress != self.controller.areTestNetworksEnabled():
    return
  let item = self.view.getModel().getItemByAddress(address, isTestAddress)
  self.loadSavedAddresses()
  self.view.savedAddressAddedOrUpdated(item.isEmpty(), name, address, errorMsg)

method savedAddressDeleted*(self: Module, address: string, isTestAddress: bool, errorMsg: string) =
  if isTestAddress != self.controller.areTestNetworksEnabled():
    return
  let item = self.view.getModel().getItemByAddress(address, isTestAddress)
  self.loadSavedAddresses()
  self.view.savedAddressDeleted(item.getName(), address, errorMsg)

method savedAddressNameExists*(self: Module, name: string): bool =
  return self.view.getModel().nameExists(name, self.controller.areTestNetworksEnabled())

method getSavedAddressAsJson*(self: Module, address: string): string =
  let item = self.view.getModel().getItemByAddress(address, self.controller.areTestNetworksEnabled())
  let jsonObj = %* {
    "name": item.getName(),
    "address": item.getAddress(),
    "ens": item.getEns(),
    "colorId": item.getColorId(),
    "chainShortNames": item.getChainShortNames(),
    "isTest": item.getIsTest(),
  }
  return $jsonObj