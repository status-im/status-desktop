import json
import ./dto/chat as chat_dto
import ../message/dto/message as message_dto
import status/statusgo_backend_new/chat as status_chat

# TODO: We need to remove these `status-lib` types from here
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

method hasChannel*(self: ServiceInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getAllChats*(self: ServiceInterface): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatsOfChatTypes*(self: ServiceInterface, types: seq[chat_dto.ChatType]): seq[ChatDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatById*(self: ServiceInterface, chatId: string): ChatDto {.base.} =
  raise newException(ValueError, "No implementation available")

method getOneToOneChatNameAndImage*(self: ServiceInterface, chatId: string): 
  tuple[name: string, image: string, isIdenticon: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method createPublicChat*(self: ServiceInterface, chatId: string): tuple[chatDto: ChatDto, success: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method createOneToOneChat*(self: ServiceInterface, chatId: string, ensName: string): tuple[chatDto: ChatDto, success: bool] {.base.} =
  raise newException(ValueError, "No implementation available")

method parseChatResponse*(self: ServiceInterface, response: string): (seq[Chat], seq[Message]) {.base.} =
  raise newException(ValueError, "No implementation available")

method parseChatResponse2*(self: ServiceInterface, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method processMessageUpdateAfterSend*(self: ServiceInterface, messageId: string, response: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method processUpdateForTransaction*(self: ServiceInterface, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method leaveChat*(self: ServiceInterface, chatId: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method sendImages*(self: ServiceInterface, chatId: string, imagePathsJson: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method requestAddressForTransaction*(self: ServiceInterface, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestTransaction*(self: ServiceInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestAddressForTransaction*(self: ServiceInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestAddressForTransaction*(self: ServiceInterface, messageId: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestTransaction*(self: ServiceInterface, transactionHash: string, messageId: string, signature: string) {.base.} =
  raise newException(ValueError, "No implementation available")