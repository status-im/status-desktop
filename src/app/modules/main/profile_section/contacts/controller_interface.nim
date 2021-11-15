import ../../../../../app_service/service/profile/service as profile_service
import ../../../../../app_service/service/contacts/dto/contacts as ContactDto
# import ./item

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContacts*(self: AccessInterface, useCache: bool = true): seq[ContactDto.ContactsDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContact*(self: AccessInterface, id: string): ContactDto.ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method generateAlias*(self: AccessInterface, publicKey: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequest*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method lookupContact*(self: AccessInterface, value: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
