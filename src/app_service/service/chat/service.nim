import Tables, json, sequtils, strformat, chronicles

import service_interface, ./dto/chat
import ../contacts/service as contact_service
import status/statusgo_backend_new/chat as status_go

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
      if chat.active and chat.chatType != ChatType.Unknown:
        self.chats[chat.id] = chat

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAllChats*(self: Service): seq[ChatDto] =
  return toSeq(self.chats.values)

method getChatsOfChatTypes*(self: Service, types: seq[ChatType]): seq[ChatDto] =
  return self.getAllChats().filterIt(it.chatType in types)

method getChatById*(self: Service, chatId: string): ChatDto =
  if(not self.chats.contains(chatId)):
    error "trying to get chat data for an unexisting chat id"
    return

  return self.chats[chatId]

method prettyChatName*(self: Service, chatId: string): string =
  let contact = self.contactService.getContactById(chatId)
  return contact.userNameOrAlias()