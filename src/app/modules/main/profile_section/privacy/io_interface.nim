import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isMnemonicBackedUp*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method changePassword*(self: AccessInterface, password: string, newPassword: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method removeMnemonic*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method mnemonicWasShown*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonicWordAtIndex*(self: AccessInterface, index: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

# Controller Delegate Interface
method mnemonicBackedUp*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPasswordChanged*(self: AccessInterface, success: bool, errorMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesFromContactsOnly*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setMessagesFromContactsOnly*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method urlUnfurlingMode*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setUrlUnfurlingMode*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method validatePassword*(self: AccessInterface, password: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getPasswordStrengthScore*(self: AccessInterface, password: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method onStoreToKeychainError*(self: AccessInterface, errorDescription: string, errorType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onStoreToKeychainSuccess*(self: AccessInterface, data: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method tryStoreToKeyChain*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method tryRemoveFromKeyChain*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method backupData*(self: AccessInterface): int64 {.base.} =
  raise newException(ValueError, "No implementation available")

method onUrlUnfurlingModeUpdated*(self: AccessInterface, mode: int) {.base.} =
  raise newException(ValueError, "No implementation available")
