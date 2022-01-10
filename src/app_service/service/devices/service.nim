import NimQml, json, sequtils, system, chronicles

import ./dto/device as device_dto
import ../settings/service as settings_service

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import status/statusgo_backend_new/installations as status_installations

export device_dto

logScope:
  topics = "devices-service"

type
  UpdateDeviceArgs* = ref object of Args
    deviceId*: string
    name*: string
    enabled*: bool

# Signals which may be emitted by this service:
const SIGNAL_UPDATE_DEVICE* = "updateDevice"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    settingsService: settings_service.ServiceInterface

  ## Forward declaration
  proc isNewDevice(self: Service, device: DeviceDto): bool

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, settingsService: settings_service.ServiceInterface): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.settingsService = settingsService

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e:Args):
      var receivedData = MessageSignal(e)
      if(receivedData.devices.len > 0):
        for d in receivedData.devices:
          let data = UpdateDeviceArgs(
            deviceId: d.id,
            name: d.metadata.name, 
            enabled: d.enabled)
          self.events.emit(SIGNAL_UPDATE_DEVICE, data)

  proc init*(self: Service) =
    self.doConnect()

  proc getAllDevices*(self: Service): seq[DeviceDto] =
    try:
      let response = status_installations.getOurInstallations()
      return map(response.result.getElems(), proc(x: JsonNode): DeviceDto = x.toDeviceDto())
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc isNewDevice(self: Service, device: DeviceDto): bool = 
    let allDevices = self.getAllDevices()
    for d in allDevices:
      if(d.id == device.id):
        return false
    return true

  proc setDeviceName*(self: Service, name: string) =
    let installationId = self.settingsService.getInstallationId()
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.setInstallationMetadata(installationId, name, hostOs)

  proc isDeviceSetup*(self: Service): bool =
    let allDevices = self.getAllDevices()
    let installationId = self.settingsService.getInstallationId()
    for d in allDevices:
      if d.id == installationId:
        return not d.metadata.isEmpty()
    return false

  proc syncAllDevices*(self: Service) =
    let preferredName = self.settingsService.getPreferredName()
    let photoPath = "" # From the old code: TODO change this to identicon when status-go is updated
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.syncDevices(preferredName, "")

  proc advertise*(self: Service) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.sendPairInstallation()

  proc enable*(self: Service, deviceId: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.enableInstallation(deviceId)

  proc disable*(self: Service, deviceId: string) =
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.disableInstallation(deviceId)