type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method mintCollectible*(self: AccessInterface, name: string, description: string, supply: int, transferable: bool,
                      selfDestruct: bool, network: string) {.base.} =
  raise newException(ValueError, "No implementation available")