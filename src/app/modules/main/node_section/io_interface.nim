import ../../../core/signals/types

type AccessInterface* {.pure, inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setPeerSize*(self: AccessInterface, peerSize: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method setLastMessage*(self: AccessInterface, lastMessage: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setStats*(self: AccessInterface, stats: Stats) {.base.} =
  raise newException(ValueError, "No implementation available")

method log*(self: AccessInterface, logContent: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendRPCMessageRaw*(self: AccessInterface, inputJSON: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setLightClient*(self: AccessInterface, enabled: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLightClient*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isFullNode*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getWakuVersion*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")
