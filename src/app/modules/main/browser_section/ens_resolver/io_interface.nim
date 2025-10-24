type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveEnsAddress*(self: AccessInterface, ensName: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveEnsResourceUrl*(self: AccessInterface, ensName: string): string {.base.} =
  raise newException(ValueError, "No implementation available")
