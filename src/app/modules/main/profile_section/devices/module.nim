import NimQml, chronicles
import io_interface
import ../io_interface as delegate_interface
import view, controller, model, item
import logging

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/devices/service as devices_service

export io_interface

logScope:
  topics = "profile-section-devices-module"

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
  devicesService: devices_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, devicesService)
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

method getMyInstallationId(self: Module): string =
  return self.controller.getMyInstallationId()

proc isMyDevice(self: Module, installationId: string): bool =
  let myInstallationId = self.controller.getMyInstallationId()
  return installationId == myInstallationId

method loadDevices*(self: Module) =
  self.view.setDevicesLoading(true)
  self.controller.asyncLoadDevices()

method onDevicesLoadingErrored*(self: Module) =
  self.view.setDevicesLoading(false)
  self.view.setDevicesLoadingError(true)

method onDevicesLoaded*(self: Module, allDevices: seq[InstallationDto]) =
  var items: seq[Item]
  for d in allDevices:
    let item = initItem(d, self.isMyDevice(d.id))
    items.add(item)
  self.view.model().addItems(items)
  self.view.setDevicesLoading(false)
  self.view.deviceSetupChanged()

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.devicesModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method setInstallationName*(self: Module, installationId: string, name: string) =
  self.controller.setInstallationName(installationId, name)
  
method syncAllDevices*(self: Module) =
  self.controller.syncAllDevices()

method advertise*(self: Module) =
  self.controller.advertise()

method enableDevice*(self: Module, installationId: string, enable: bool) =
  self.controller.enableDevice(installationId, enable)

method updateOrAddDevice*(self: Module, installation: InstallationDto) =
  if(self.view.model().isItemWithInstallationIdAdded(installation.id)):
    self.view.model().updateItem(installation)
  else:
    let item = initItem(installation, self.isMyDevice(installation.id))
    self.view.model().addItem(item)

method updateInstallationName*(self: Module, installationId: string, name: string) =
  self.view.model().updateItemName(installationId, name)

method authenticateUser*(self: Module, keyUid: string) =
  self.controller.authenticateUser(keyUid)

method onUserAuthenticated*(self: Module, pin: string, password: string, keyUid: string) =
  self.view.emitUserAuthenticated(pin, password, keyUid)

proc validateConnectionString*(self: Module, connectionString: string): string =
  return self.controller.validateConnectionString(connectionString)

method getConnectionStringForBootstrappingAnotherDevice*(self: Module, keyUid: string, password: string): string =
  return self.controller.getConnectionStringForBootstrappingAnotherDevice(keyUid, password)

method inputConnectionStringForBootstrapping*(self: Module, connectionString: string): string =
  return self.controller.inputConnectionStringForBootstrapping(connectionString)

method onLocalPairingEvent*(self: Module, eventType: EventType, action: Action, error: string) =
  self.view.onLocalPairingEvent(eventType, action, error)

method onLocalPairingStatusUpdate*(self: Module, status: LocalPairingStatus) =
  self.view.onLocalPairingStatusUpdate(status)