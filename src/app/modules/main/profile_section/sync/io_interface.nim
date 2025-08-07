import nimqml

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

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getUseMailservers*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setUseMailservers*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method performLocalBackup*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method importLocalBackupFile*(self: AccessInterface, filePath: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onLocalBackupImportCompleted*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")
