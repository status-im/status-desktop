import nimqml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/node_configuration/service as node_configuration_service

export io_interface

logScope:
  topics = "profile-section-waku-module"

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
  nodeConfigurationService: node_configuration_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, nodeConfigurationService)
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

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.wakuModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getActiveMailserver*(self: Module): string =
  return self.view.getActiveMailserver()

method onActiveMailserverChanged*(self: Module, activeMailserverId: string) =
  self.view.onActiveMailserverChanged(activeMailserverId)
