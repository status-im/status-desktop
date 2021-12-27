import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
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
    return self.delegate.isDeviceSetup()
  QtProperty[bool] isDeviceSetup:
    read = getIsDeviceSetup
    notify = deviceSetupChanged
  
  proc emitDeviceSetupChangedSignal*(self: View) =
    self.deviceSetupChanged()

  proc setName*(self: View, deviceName: string) {.slot.} =
    self.delegate.setDeviceName(deviceName)

  proc syncAll*(self: View) {.slot.} =
    self.delegate.syncAllDevices()

  proc advertise*(self: View) {.slot.} =
    self.delegate.advertise()

  proc enableDevice*(self: View, installationId: string, enable: bool) {.slot.} =
    self.delegate.enableDevice(installationId, enable)