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

# Controller Delegate Interface
method onMnemonicUpdated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPasswordChanged*(self: AccessInterface, success: bool, errorMsg: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getMessagesFromContactsOnly*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setMessagesFromContactsOnly*(self: AccessInterface, value: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method validatePassword*(self: AccessInterface, password: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfilePicturesShowTo*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setProfilePicturesShowTo*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getProfilePicturesVisibility*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setProfilePicturesVisibility*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPasswordStrengthScore*(self: AccessInterface, password: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method emitProfilePicturesShowToChanged*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitProfilePicturesVisibilityChanged*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

