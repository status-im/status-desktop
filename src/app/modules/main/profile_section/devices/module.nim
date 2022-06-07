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

proc isMyDevice(self: Module, installationId: string): bool =
  let myInstallationId = self.controller.getMyInstallationId()
  return installationId == myInstallationId

proc initModel(self: Module) =
  var items: seq[Item]
  let allDevices = self.controller.getAllDevices()
  var logger = newConsoleLogger()
  logger.log(lvlInfo, "<-- Listing all devices:")
  for d in allDevices:
    logger.log(lvlInfo, d)
    let item = initItem(d.id, d.metadata.name, d.enabled, self.isMyDevice(d.id))
    items.add(item)

  self.view.model().addItems(items)

method viewDidLoad*(self: Module) =
  self.initModel()
  self.moduleLoaded = true
  self.delegate.devicesModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method isDeviceSetup*(self: Module): bool =
  return self.controller.isDeviceSetup()

method setDeviceName*(self: Module, name: string) =
  self.controller.setDeviceName(name)
  # in future if we start getting more meaningful response form the `status-go` part, we may
  # move this call to the `onDeviceNameSet` slot and confirm change on the qml side that way.
  self.view.emitDeviceSetupChangedSignal()

method syncAllDevices*(self: Module) =
  self.controller.syncAllDevices()

method advertise*(self: Module) =
  self.controller.advertise()

method enableDevice*(self: Module, deviceId: string, enable: bool) =
  self.controller.enableDevice(deviceId, enable)

method updateOrAddDevice*(self: Module, deviceId: string, name: string, enabled: bool) =
  if(self.view.model().isItemWithInstallationIdAdded(deviceId)):
    self.view.model().updateItem(deviceId, name, enabled)
  else:
    let item = initItem(deviceId, name, enabled, self.isMyDevice(deviceId))
    self.view.model().addItem(item)
