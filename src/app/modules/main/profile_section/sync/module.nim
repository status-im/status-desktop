import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, model, item

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/general/service as general_service
import app_service/service/settings/service as settings_service
import app_service/service/mailservers/service as mailservers_service
import app_service/service/node_configuration/service as node_configuration_service

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

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
    mailserversService: mailservers_service.Service,
    generalService: general_service.Service,
  ): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, nodeConfigurationService,
    mailserversService, generalService)
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
  return self.controller.getPinnedMailserverId().len == 0

method onActiveMailserverChanged*(self: Module) =
  self.view.onActiveMailserverSet()

method onPinnedMailserverChanged*(self: Module) =
  self.view.onPinnedMailserverSet()

method setPinnedMailserverId*(self: Module, mailserverID: string) =
  self.controller.setPinnedMailserverId(mailserverID)

method getPinnedMailserverId*(self: Module): string =
  return self.controller.getPinnedMailserverId()

method getActiveMailserverId*(self: Module): string =
  let res = self.controller.getActiveMailserverId()
  return res

method saveNewMailserver*(self: Module, name: string, nodeAddress: string) =
  self.controller.saveNewMailserver(name, nodeAddress)

  let item = initItem(name, nodeAddress)
  self.view.model().addItem(item)

method enableAutomaticSelection*(self: Module, value: bool) =
  self.controller.enableAutomaticSelection(value)

method getUseMailservers*(self: Module): bool =
  return self.controller.getUseMailservers()

method setUseMailservers*(self: Module, value: bool) =
  if self.controller.setUseMailservers(value):
    self.view.useMailserversChanged()

method importLocalBackupFile*(self: Module, filePath: string) =
  let formattedFilePath = singletonInstance.utils.fromPathUri(filePath)
  self.controller.importLocalBackupFile(formattedFilePath)

method onLocalBackupImportCompleted*(self: Module, error: string) =
  self.view.setBackupImportState(BackupImportState.Completed)
  self.view.setBackupImportError(error)
