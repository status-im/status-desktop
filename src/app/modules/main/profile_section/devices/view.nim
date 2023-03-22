import NimQml
import io_interface, model
import ../../../../../app_service/service/devices/service


QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      devicesLoading: bool
      devicesLoadingError: bool
      localPairingStatus: LocalPairingStatus

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete
    self.localPairingStatus.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.devicesLoading = false
    result.devicesLoadingError = false
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.localPairingStatus = newLocalPairingStatus()

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

  proc setInstallationName*(self: View, installationId: string, name: string) {.slot.} =
    self.delegate.setInstallationName(installationId, name)

  proc syncAll*(self: View) {.slot.} =
    self.delegate.syncAllDevices()

  proc advertise*(self: View) {.slot.} =
    self.delegate.advertise()

  proc enableDevice*(self: View, installationId: string, enable: bool) {.slot.} =
    self.delegate.enableDevice(installationId, enable)

  # LocalPairing status

  proc localPairingStatusChanged*(self: View) {.signal.}

  proc getLocalPairingState*(self: View): int {.slot.} =
    return self.localPairingStatus.state.int
  QtProperty[int] localPairingState:
    read = getLocalPairingState
    notify = localPairingStatusChanged

  proc getLocalPairingError*(self: View): string {.slot.}  =
    return self.localPairingStatus.error
  proc localPairingPairingErrorChanged*(self: View) {.signal.}
  QtProperty[string] localPairingError:
    read = getLocalPairingError
    notify = localPairingStatusChanged

  proc localPairingEvent(self: View, eventType: int, action: int, error: string) {.signal.}
  proc onLocalPairingEvent*(self: View, eventType: EventType, action: Action, error: string) =
    self.localPairingEvent(ord(eventType), ord(action), error)

  proc onLocalPairingStatusUpdate*(self: View, status: LocalPairingStatus) =
    self.localPairingStatus = status
    self.localPairingStatusChanged()

  # LocalPairing actions

  proc userAuthenticated*(self: View, pin: string, password: string, keyUid: string) {.signal.}
  proc emitUserAuthenticated*(self: View, pin: string, password: string, keyUid: string) =
    self.userAuthenticated(pin, password, keyUid)
  proc authenticateUser*(self: View, keyUid: string) {.slot.} =
    self.delegate.authenticateUser(keyUid)

  proc validateConnectionString*(self: View, connectionString: string): string {.slot.} =
    return self.delegate.validateConnectionString(connectionString)

  proc getConnectionStringForBootstrappingAnotherDevice*(self: View, keyUid: string, password: string): string {.slot.} =
    return self.delegate.getConnectionStringForBootstrappingAnotherDevice(keyUid, password)

  proc inputConnectionStringForBootstrapping*(self: View, connectionString: string): string {.slot.} =
    return self.delegate.inputConnectionStringForBootstrapping(connectionString)
