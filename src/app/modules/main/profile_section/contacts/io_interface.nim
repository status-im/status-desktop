import NimQml

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToOrCreateOneToOneChat*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptContactRequests*(self: AccessInterface, publicKeysJSON: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequests*(self: AccessInterface, publicKeysJSON: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContactRequestRejection*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# Controller Delegate Interface

method contactAdded*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactBlocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUnblocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactRemoved*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactNicknameChanged*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactRequestRejectionRemoved*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")