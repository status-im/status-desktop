import Tables, json, sequtils, strformat, chronicles

import service_interface
import ./dto/chat as chat_dto
import ../contacts/service as contact_service
import status/statusgo_backend_new/chat as status_go
import status/types/[message]
import status/types/chat as chat_type

export service_interface

logScope:
  topics = "chat-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    contactService: contact_service.Service

method delete*(self: Service) =
  discard

proc newService*(contactService: contact_service.Service): Service =
  result = Service()
  result.contactService = contactService
  result.chats = initTable[string, ChatDto]()

method init*(self: Service) =
  try:
    let response = status_go.getChats()

    let chats = map(response.result.getElems(), proc(x: JsonNode): ChatDto = x.toChatDto())

    for chat in chats:
      if chat.active and chat.chatType != chat_dto.ChatType.Unknown:
        self.chats[chat.id] = chat

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAllChats*(self: Service): seq[ChatDto] =
  return toSeq(self.chats.values)

method getChatsOfChatTypes*(self: Service, types: seq[chat_dto.ChatType]): seq[ChatDto] =
  return self.getAllChats().filterIt(it.chatType in types)

method getChatById*(self: Service, chatId: string): ChatDto =
  if(not self.chats.contains(chatId)):
    error "trying to get chat data for an unexisting chat id"
    return

  return self.chats[chatId]

method prettyChatName*(self: Service, chatId: string): string =
  let contact = self.contactService.getContactById(chatId)
  return contact.userNameOrAlias()

# TODO refactor this to new object types
proc parseChatResponse*(self: Service, response: string): (seq[Chat], seq[Message]) =
  var parsedResponse = parseJson(response)
  var chats: seq[Chat] = @[]
  var messages: seq[Message] = @[]
  if parsedResponse{"result"}{"messages"} != nil:
    for jsonMsg in parsedResponse["result"]["messages"]:
      messages.add(jsonMsg.toMessage())
  if parsedResponse{"result"}{"chats"} != nil:
    for jsonChat in parsedResponse["result"]["chats"]:
      let chat = jsonChat.toChat
      # TODO add the channel back to `chat` when it is refactored
      # self.channels[chat.id] = chat
      chats.add(chat) 
  result = (chats, messages)