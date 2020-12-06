import NimQml, chronicles
import ../../../status/status
import ../../../status/devices as status_devices
import ../../../status/profile/devices
import device_list

logScope:
  topics = "devices-view"

QtObject:
  type DevicesView* = ref object of QObject
    status: Status
    deviceList*: DeviceList
    isDeviceSetup: bool

  proc setup(self: DevicesView) =
    self.QObject.setup

  proc delete*(self: DevicesView) =
    if not self.deviceList.isNil: self.deviceList.delete
    self.QObject.delete

  proc newDevicesView*(status: Status): DevicesView =
    new(result, delete)
    result.status = status
    result.deviceList = newDeviceList()
    result.isDeviceSetup = false
    result.setup

  proc isDeviceSetup*(self: DevicesView): bool {.slot} =
    result = self.isDeviceSetup

  proc deviceSetupChanged*(self: DevicesView) {.signal.}

  proc setDeviceSetup*(self: DevicesView, isSetup: bool) {.slot} =
    self.isDeviceSetup = isSetup
    self.deviceSetupChanged()

  QtProperty[bool] isSetup:
    read = isDeviceSetup
    notify = deviceSetupChanged

  proc setName*(self: DevicesView, deviceName: string) {.slot.} =
    status_devices.setDeviceName(deviceName)
    self.setDeviceSetup(true)

  proc syncAll*(self: DevicesView) {.slot.} =
    status_devices.syncAllDevices()

  proc advertise*(self: DevicesView) {.slot.} =
    status_devices.advertise()

  proc addDevices*(self: DevicesView, devices: seq[Installation]) =
    for dev in devices:
      self.deviceList.addDeviceToList(dev)

  proc getDeviceList(self: DevicesView): QVariant {.slot.} =
    return newQVariant(self.deviceList)

  QtProperty[QVariant] list:
    read = getDeviceList

  proc enableInstallation*(self: DevicesView, installationId: string, enable: bool) {.slot.} =
    if enable:
      status_devices.enable(installationId)
    else:
      status_devices.disable(installationId)


