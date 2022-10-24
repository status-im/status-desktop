import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveMailserverChanged*(self: AccessInterface, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isAutomaticSelection*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMailserverNameForNodeAddress*(self: AccessInterface, nodeAddress: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveMailserver*(self: AccessInterface, mailserverID: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method saveNewMailserver*(self: AccessInterface, name: string, nodeAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method enableAutomaticSelection*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method getUseMailservers*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setUseMailservers*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")
