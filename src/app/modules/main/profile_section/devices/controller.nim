import Tables, chronicles
import controller_interface
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/devices/service as devices_service

export controller_interface

logScope:
  topics = "profile-section-devices-module-controller"

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    devicesService: devices_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.ServiceInterface,
  devicesService: devices_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.devicesService = devicesService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_UPDATE_DEVICE) do(e: Args):
    var args = UpdateDeviceArgs(e)
    self.delegate.updateOrAddDevice(args.deviceId, args.name, args.enabled)

method getMyInstallationId*(self: Controller): string =
  return self.settingsService.getInstallationId()

method getAllDevices*(self: Controller): seq[DeviceDto] =
  return self.devicesService.getAllDevices()

method isDeviceSetup*(self: Controller): bool =
  return self.devicesService.isDeviceSetup()

method setDeviceName*(self: Controller, name: string) =
  self.devicesService.setDeviceName(name)

method syncAllDevices*(self: Controller) =
  self.devicesService.syncAllDevices()

method advertise*(self: Controller) =
  self.devicesService.advertise()

method enableDevice*(self: Controller, deviceId: string, enable: bool) =
  if enable:
    self.devicesService.enable(deviceId)
  else:
    self.devicesService.disable(deviceId)
