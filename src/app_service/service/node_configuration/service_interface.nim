import chronicles
import ./dto/node_config

export node_config
export chronicles

const WAKU_VERSION_1* = 1
const WAKU_VERSION_2* = 2
const BLOOM_LEVEL_NORMAL* = "normal"
const BLOOM_LEVEL_FULL* = "full"
const BLOOM_LEVEL_LIGHT* = "light"

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuVersion*(self: ServiceInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getBloomLevel*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setWakuVersion*(self: ServiceInterface, wakuVersion: int): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setNetwork*(self: ServiceInterface, network: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomFilterMode*(self: ServiceInterface, bloomFilterMode: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: ServiceInterface, bloomLevel: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setFleet*(self: ServiceInterface, fleet: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getV2LightMode*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setV2LightMode*(self: ServiceInterface, enabled: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getDebugLevel*(self: ServiceInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setDebugLevel*(self: ServiceInterface, logLevel: LogLevel): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isV2LightMode*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isFullNode*(self: ServiceInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")