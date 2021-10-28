import NimQml
# import status/status
import status/types/[installation]
import device_list

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      deviceList*: DeviceList
      isDeviceSetup: bool

  proc delete*(self: View) =
    if not self.deviceList.isNil: self.deviceList.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.deviceList = newDeviceList()
    result.isDeviceSetup = false
    result.delegate = delegate

  proc isDeviceSetup*(self: View): bool {.slot} =
    result = self.isDeviceSetup

  proc deviceSetupChanged*(self: View) {.signal.}

  proc setDeviceSetup*(self: View, isSetup: bool) {.slot} =
    self.isDeviceSetup = isSetup
    self.deviceSetupChanged()

  QtProperty[bool] isSetup:
    read = isDeviceSetup
    notify = deviceSetupChanged

  proc setName*(self: View, deviceName: string) {.slot.} =
    self.delegate.setDeviceName(deviceName)
    self.setDeviceSetup(true)

  proc syncAll*(self: View) {.slot.} =
    self.delegate.syncAllDevices()

  proc advertise*(self: View) {.slot.} =
    self.delegate.advertiseDevice()

  proc addDevices*(self: View, devices: seq[Installation]) =
    for dev in devices:
      self.deviceList.addDeviceToList(dev)

  proc getDeviceList(self: View): QVariant {.slot.} =
    return newQVariant(self.deviceList)

  QtProperty[QVariant] list:
    read = getDeviceList

  proc enableInstallation*(self: View, installationId: string, enable: bool) {.slot.} =
    self.delegate.enableInstallation(installationId, enable)
