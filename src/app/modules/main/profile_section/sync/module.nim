import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, model, item

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/mailservers/service as mailservers_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

export io_interface

logScope:
  topics = "profile-section-sync-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  mailserversService: mailservers_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, nodeConfigurationService, mailserversService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

proc initModel(self: Module) =
  var items: seq[Item]
  let allMailservers = self.controller.getAllMailservers()
  for ms in allMailservers:
    let item = initItem(ms.name, ms.nodeAddress)
    items.add(item)

  self.view.model().addItems(items)

method viewDidLoad*(self: Module) =
  self.initModel()
  self.moduleLoaded = true
  self.delegate.syncModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method isAutomaticSelection*(self: Module): bool =
  return self.controller.getPinnedMailserver().len == 0

method onActiveMailserverChanged*(self: Module, nodeAddress: string) =
  self.view.onActiveMailserverSet(nodeAddress)

method getMailserverNameForNodeAddress*(self: Module, nodeAddress: string): string =
  let name = self.view.model().getNameForNodeAddress(nodeAddress)
  if(name.len > 0):
    return name
  return "---"

method setActiveMailserver*(self: Module, mailserverID: string) =
  self.controller.pinMailserver(mailserverID)

method saveNewMailserver*(self: Module, name: string, nodeAddress: string) =
  self.controller.saveNewMailserver(name, nodeAddress)

  let item = initItem(name, nodeAddress)
  self.view.model().addItem(item)

method enableAutomaticSelection*(self: Module, value: bool) =
  self.controller.enableAutomaticSelection(value)

method getUseMailservers*(self: Module): bool =
  return self.controller.getUseMailservers()

method setUseMailservers*(self: Module, value: bool) =
  if (self.controller.setUseMailservers(value)):
    self.view.useMailserversChanged()
