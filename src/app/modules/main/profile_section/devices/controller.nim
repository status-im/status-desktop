import Tables, chronicles
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/devices/service as devices_service

logScope:
  topics = "profile-section-devices-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    devicesService: devices_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  devicesService: devices_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.devicesService = devicesService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_DEVICES_LOADED) do(e: Args):
    var args = DevicesArg(e)
    self.delegate.onDevicesLoaded(args.devices)

  self.events.on(SIGNAL_ERROR_LOADING_DEVICES) do(e: Args):
    self.delegate.onDevicesLoadingErrored()

  self.events.on(SIGNAL_UPDATE_DEVICE) do(e: Args):
    var args = UpdateDeviceArgs(e)
    self.delegate.updateOrAddDevice(args.deviceId, args.name, args.enabled)

proc getMyInstallationId*(self: Controller): string =
  return self.settingsService.getInstallationId()

proc asyncLoadDevices*(self: Controller) =
  self.devicesService.asyncLoadDevices()

proc setDeviceName*(self: Controller, name: string) =
  self.devicesService.setDeviceName(name)

proc syncAllDevices*(self: Controller) =
  self.devicesService.syncAllDevices()

proc advertise*(self: Controller) =
  self.devicesService.advertise()

proc enableDevice*(self: Controller, deviceId: string, enable: bool) =
  if enable:
    self.devicesService.enable(deviceId)
  else:
    self.devicesService.disable(deviceId)
