import dto, types

export dto, types

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworks*(self: ServiceInterface, useCached: bool = true): seq[NetworkDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method upsertNetwork*(self: ServiceInterface, network: NetworkDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method deleteNetwork*(self: ServiceInterface, network: NetworkDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetwork*(self: ServiceInterface, networkType: NetworkType): NetworkDto {.base.} =
  raise newException(ValueError, "No implementation available")
