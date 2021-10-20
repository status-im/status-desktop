import dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getContact*(self: ServiceInterface, id: string): Dto {.base.} =
  raise newException(ValueError, "No implementation available")

method getOrCreateContact*(self: ServiceInterface, id: string): Dto {.base.} =
  raise newException(ValueError, "No implementation available")

method saveContact*(self: ServiceInterface, contact: Dto) {.base.} =
  raise newException(ValueError, "No implementation available")

method addContact*(self: ServiceInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method rejectContactRequest*(self: ServiceInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method changeContactNickname*(self: ServiceInterface, accountKeyUID: string, publicKey: string, nicknameToSet: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method unblockContact*(self: ServiceInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method blockContact*(self: ServiceInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeContact*(self: ServiceInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")