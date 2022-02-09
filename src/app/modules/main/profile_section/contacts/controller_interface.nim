import ../../../../../app_service/service/contacts/dto/contacts as contacts_dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContacts*(self: AccessInterface): seq[ContactsDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getContact*(self: AccessInterface, id: string): ContactsDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactNameAndImage*(self: AccessInterface, contactId: string):
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: AccessInterface, publicKey: string): void {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: AccessInterface, publicKey: string, nickname: string) {.base.} =
  raise newException(ValueError, "No implementation available")
