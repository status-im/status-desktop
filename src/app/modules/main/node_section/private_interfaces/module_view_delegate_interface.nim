import json
import status/types/[rpc_response]

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available") 

method sendRPCMessageRaw*(self: AccessInterface, inputJSON: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomFilterMode*(self: AccessInterface, bloomFilterMode: bool){.base.} =
  raise newException(ValueError, "No implementation available")

method setBloomLevel*(self: AccessInterface, level: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setV2LightMode*(self: AccessInterface, enabled: bool) {.base.} =
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
