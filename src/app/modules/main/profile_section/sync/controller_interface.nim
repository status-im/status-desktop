type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllMailservers*(self: AccessInterface): seq[tuple[name: string, nodeAddress: string]] {.base.} =
  raise newException(ValueError, "No implementation available")

method getPinnedMailserver*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method pinMailserver*(self: AccessInterface, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNewMailserver*(self: AccessInterface, name: string, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableAutomaticSelection*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")