type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isMnemonicBackedUp*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getLinkPreviewWhitelist*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method changePassword*(self: AccessInterface, password: string, newPassword: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMnemonic*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonicWordAtIndex*(self: AccessInterface, index: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesFromContactsOnly*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setMessagesFromContactsOnly*(self: AccessInterface, value: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method validatePassword*(self: AccessInterface, password: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")
