import json

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendRPCMessageRaw*(self: AccessInterface, inputJSON: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomFilterMode*(self: AccessInterface, bloomFilterMode: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: AccessInterface, level: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getNodeConfig*(self: AccessInterface): JsonNode {.base.} =
  raise newException(ValueError, "No implementation available")

method setV2LightMode*(self: AccessInterface, enabled: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuBloomFilterMode*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method fetchBitsSet*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isV2LightMode*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isFullNode*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuVersion*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getBloomLevel*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")
