method onCurrentNetworkSet*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method onFleetSet*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
  
method onBloomLevelSet*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method onWakuV2LightClientSet*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTelemetryToggled*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method onAutoMessageToggled*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method onDebugToggled*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")