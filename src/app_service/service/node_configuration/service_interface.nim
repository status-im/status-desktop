import ./dto/node_config

export node_config

const WAKU_VERSION_1* = 1
const WAKU_VERSION_2* = 2

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuVersion*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setWakuVersion*(self: ServiceInterface, wakuVersion: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method setNetwork*(self: ServiceInterface, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomFilterMode*(self: ServiceInterface, bloomFilterMode: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: ServiceInterface, bloomFilterMode: bool, fullNode: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setFleet*(self: ServiceInterface, fleet: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setV2LightMode*(self: ServiceInterface, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")