import ../../../../../app_service/service/settings/dto/settings as settings_service_type

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkDetails*(self: AccessInterface): settings_service_type.Network {.base.} =
  raise newException(ValueError, "No implementation available")

method changeCurrentNetworkTo*(self: AccessInterface, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getFleet*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method changeFleetTo*(self: AccessInterface, fleet: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getBloomLevel*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: AccessInterface, bloomLevel: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuV2LightClientEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setWakuV2LightClientEnabled*(self: AccessInterface, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableDeveloperFeatures*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleTelemetry*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isTelemetryEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleAutoMessage*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isAutoMessageEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleDebug*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isDebugEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getCustomNetworks*(self: AccessInterface): seq[settings_service_type.Network] {.base.} =
  raise newException(ValueError, "No implementation available")

method addCustomNetwork*(self: AccessInterface, network: Network) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleWalletSection*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleBrowserSection*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleCommunitySection*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleNodeManagementSection*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
