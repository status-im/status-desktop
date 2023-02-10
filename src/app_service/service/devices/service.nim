import NimQml, json, sequtils, system, chronicles

import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ./dto/device as device_dto
import ../settings/service as settings_service

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../backend/installations as status_installations

export device_dto
include async_tasks

logScope:
  topics = "devices-service"

type
  UpdateDeviceArgs* = ref object of Args
    deviceId*: string
    name*: string
    enabled*: bool

type
  DevicesArg* = ref object of Args
    devices*: seq[DeviceDto]

# Signals which may be emitted by this service:
const SIGNAL_UPDATE_DEVICE* = "updateDevice"
const SIGNAL_DEVICES_LOADED* = "devicesLoaded"
const SIGNAL_ERROR_LOADING_DEVICES* = "devicesErrorLoading"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      settingsService: settings_service.Service,
    ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.settingsService = settingsService
    result.threadpool = threadpool

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

  proc asyncLoadDevices*(self: Service) =
    let arg = AsyncLoadDevicesTaskArg(
      tptr: cast[ByteAddress](asyncLoadDevicesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncDevicesLoaded",
    )
    self.threadpool.start(arg)

  proc asyncDevicesLoaded*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponse = Json.decode(response, RpcResponse[JsonNode])
      let installations = map(rpcResponse.result.getElems(), proc(x: JsonNode): DeviceDto = x.toDeviceDto())
      self.events.emit(SIGNAL_DEVICES_LOADED, DevicesArg(devices: installations))
    except Exception as e:
      let errDesription = e.msg
      error "error loading devices: ", errDesription
      self.events.emit(SIGNAL_ERROR_LOADING_DEVICES, Args())

  proc getAllDevices*(self: Service): seq[DeviceDto] =
    try:
      let response = status_installations.getOurInstallations()
      return map(response.result.getElems(), proc(x: JsonNode): DeviceDto = x.toDeviceDto())
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription

  proc setDeviceName*(self: Service, name: string) =
    let installationId = self.settingsService.getInstallationId()
    # Once we get more info from `status-go` we may emit success/failed signal from here.
    discard status_installations.setInstallationMetadata(installationId, name, hostOs)

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
