import ./dto/chat as chat_dto
import status/types/[message]
import status/types/chat as chat_type

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

method getChatsOfChatTypes*(self: ServiceInterface, types: seq[chat_dto.ChatType]): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatById*(self: ServiceInterface, chatId: string): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method prettyChatName*(self: ServiceInterface, chatId: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method parseChatResponse*(self: ServiceInterface, response: string): (seq[Chat], seq[Message]) {.base.} =
  raise newException(ValueError, "No implementation available")