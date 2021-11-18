import ../../../../../app_service/service/contacts/dto/contacts

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setContactList*(self: AccessInterface, contacts: seq[ContactsDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateContactList*(self: AccessInterface, contacts: seq[ContactsDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getContact*(self: AccessInterface, id: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method generateAlias*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactAdded*(self: AccessInterface, contact: ContactsDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactBlocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUnblocked*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactRemoved*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactNicknameChanged*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequest*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method lookupContact*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactLookedUp*(self: AccessInterface, id: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
