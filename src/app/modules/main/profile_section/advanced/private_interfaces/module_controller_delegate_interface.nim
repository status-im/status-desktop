import ../../../../../../app_service/service/settings/dto/settings as settings_service_type

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

method onCustomNetworkAdded*(self: AccessInterface, network: settings_service_type.Network) {.base.} =
  raise newException(ValueError, "No implementation available")
