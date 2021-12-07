
type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
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

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    