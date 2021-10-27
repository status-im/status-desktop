import ./dto/chat as chat_dto

export chat_dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllChats*(self: ServiceInterface): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatsOfChatTypes*(self: ServiceInterface, types: seq[ChatType]): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatById*(self: ServiceInterface, chatId: string): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")