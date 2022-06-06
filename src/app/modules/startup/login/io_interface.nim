import NimQml, item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method emitAccountLoginError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordError*(self: AccessInterface, errorDescription: string)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordSuccess*(self: AccessInterface, password: string)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedAccount*(self: AccessInterface, item: Item) {.base.} =
  raise newException(ValueError, "No implementation available")

method login*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")