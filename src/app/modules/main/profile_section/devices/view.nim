import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      devicesLoading: bool
      devicesLoadingError: bool

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.devicesLoading = false
    result.devicesLoadingError = false
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc deviceSetupChanged*(self: View) {.signal.}
  proc getIsDeviceSetup*(self: View): bool {.slot} =
    return self.model.getIsDeviceSetup(self.delegate.getMyInstallationId())
  QtProperty[bool] isDeviceSetup:
    read = getIsDeviceSetup
    notify = deviceSetupChanged

  proc devicesLoadingChanged*(self: View) {.signal.}
  proc setDevicesLoading*(self: View, value: bool) =
    if self.devicesLoading == value:
      return
    self.devicesLoading = value
    self.devicesLoadingChanged()
  proc getDevicesLoading*(self: View): bool {.slot} =
    return self.devicesLoading
  QtProperty[bool] devicesLoading:
    read = getDevicesLoading
    notify = devicesLoadingChanged

  proc devicesLoadingErrorChanged*(self: View) {.signal.}
  proc setDevicesLoadingError*(self: View, value: bool) =
    if self.devicesLoadingError == value:
      return
    self.devicesLoadingError = value
    self.devicesLoadingErrorChanged()
  proc getDevicesLoadingError*(self: View): bool {.slot} =
    return self.devicesLoadingError
  QtProperty[bool] devicesLoadingError:
    read = getDevicesLoadingError
    notify = devicesLoadingErrorChanged

  proc loadDevices*(self: View) {.slot.} =
    self.delegate.loadDevices()

  proc setName*(self: View, deviceName: string) {.slot.} =
    self.delegate.setDeviceName(deviceName)

  proc syncAll*(self: View) {.slot.} =
    self.delegate.syncAllDevices()

  proc advertise*(self: View) {.slot.} =
    self.delegate.advertise()

  proc enableDevice*(self: View, installationId: string, enable: bool) {.slot.} =
    self.delegate.enableDevice(installationId, enable)
