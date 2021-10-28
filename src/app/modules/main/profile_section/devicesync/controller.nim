import ./controller_interface
import eventemitter
import io_interface
import status/types/[installation]
import status/signals
import ../../../../../app_service/service/devicesync/service as devicesync_service

# import ./item as item

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    deviceSyncService: devicesync_service.ServiceInterface

proc newController*[T](delegate: io_interface.AccessInterface,
  events: EventEmitter,
  deviceSyncService: devicesync_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.events = events
  result.delegate = delegate
  result.deviceSyncService = deviceSyncService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  self.events.on(SignalType.Message.event) do(e: Args):
    let msgData = MessageSignal(e);
    if msgData.installations.len > 0:
      self.delegate.addDevices(msgData.installations)

method setDeviceName*[T](self: Controller[T], deviceName: string) =
  self.deviceSyncService.setDeviceName(deviceName)

method syncAllDevices*[T](self: Controller[T]) =
  self.deviceSyncService.syncAllDevices()

method advertiseDevice*[T](self: Controller[T]) =
  self.deviceSyncService.advertiseDevice()

method getAllDevices*[T](self: Controller[T]): seq[Installation] =
  self.deviceSyncService.getAllDevices()

method isDeviceSetup*[T](self: Controller[T]): bool =
  self.deviceSyncService.isDeviceSetup()

method enableInstallation*[T](self: Controller[T], installationId: string, enable: bool) =
  self.deviceSyncService.enableInstallation(installationId, enable)
