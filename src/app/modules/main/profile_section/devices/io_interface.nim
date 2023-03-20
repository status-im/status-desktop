import NimQml
import ../../../../../app_service/service/devices/service


type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method updateOrAddDevice*(self: AccessInterface, installation: InstallationDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateInstallationName*(self: AccessInterface, installationId: string, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMyInstallationId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onDevicesLoaded*(self: AccessInterface, allDevices: seq[InstallationDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDevicesLoadingErrored*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadDevices*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setInstallationName*(self: AccessInterface, installationId: string, name: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncAllDevices*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method advertise*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableDevice*(self: AccessInterface, installationId: string, enable: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

proc validateConnectionString*(self: AccessInterface, connectionString: string): string =
  raise newException(ValueError, "No implementation available")

method getConnectionStringForBootstrappingAnotherDevice*(self: AccessInterface, keyUid: string, password: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method inputConnectionStringForBootstrapping*(self: AccessInterface, connectionString: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onLocalPairingEvent*(self: AccessInterface, eventType: EventType, action: Action, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onLocalPairingStatusUpdate*(self: AccessInterface, status: LocalPairingStatus) {.base.} =
  raise newException(ValueError, "No implementation available")