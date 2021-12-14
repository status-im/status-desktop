method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method getCurrentNetworkName*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentNetworkId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setCurrentNetwork*(self: AccessInterface, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getFleet*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setFleet*(self: AccessInterface, fleet: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLogDir*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getBloomLevel*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: AccessInterface, bloomLevel: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuV2LightClientEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setWakuV2LightClientEnabled*(self: AccessInterface, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method isTelemetryEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")
  
method toggleTelemetry*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isAutoMessageEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleAutoMessage*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isDebugEnabled*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleDebug*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")