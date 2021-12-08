import NimQml, Tables, json, sequtils, strformat, chronicles

import ./dto/chat as chat_dto
import ../contacts/service as contact_service
import status/statusgo_backend_new/chat as status_chat

# TODO: We need to remove these `status-lib` types from here
import status/types/[message]
import status/types/chat as chat_type

import eventemitter

export chat_dto


logScope:
  topics = "chat-service"

include ../../common/json_utils

type
  ChatArgs* = ref object of Args
    chatId*: string

# Remove new when old code is removed
const SIGNAL_CHAT_MUTED* = "new-chatMuted"
const SIGNAL_CHAT_UNMUTED* = "new-chatUnmuted"
const SIGNAL_CHAT_HISTORY_CLEARED* = "new-chatHistoryCleared"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    contactService: contact_service.Service

  method delete*(self: Service) =
    discard

  proc newService*(events: EventEmitter, contactService: contact_service.Service): Service =
    result = Service()
    result.events = events
    result.contactService = contactService
    result.chats = initTable[string, ChatDto]()

  method init*(self: Service) =
    try:
      let response = status_chat.getChats()

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

  method getOneToOneChatNameAndImage*(self: Service, chatId: string): 
    tuple[name: string, image: string, isIdenticon: bool] =
    return self.contactService.getContactNameAndImage(chatId)

  method createPublicChat*(self: Service, chatId: string): tuple[chatDto: ChatDto, success: bool] =
    try:
      let response = status_chat.createPublicChat(chatId)
      var jsonArr: JsonNode
      if (not response.result.getProp("chats", jsonArr)):
        error "error: response of creating public chat doesn't contain created chats for chat: ", chatId
        result.success = false
        return

      let chats = map(jsonArr.getElems(), proc(x: JsonNode): ChatDto = x.toChatDto())
      # created chat is returned as the first elemnt of json array (it's up to `status-go`)
      if(chats.len == 0):
        error "error: unknown error occured creating public chat ", chatId
        result.success = false
        return

      result.chatDto = chats[0]
      result.success = true

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  method muteChat*(self: Service, chatId: string) =
    try:
      let response = status_chat.muteChat(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId 
        error "error while mute chat ", msg
        return

      self.events.emit(SIGNAL_CHAT_MUTED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  method unmuteChat*(self: Service, chatId: string) =
    try:
      let response = status_chat.unmuteChat(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId 
        error "error while unmute chat ", msg
        return
      
      self.events.emit(SIGNAL_CHAT_UNMUTED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  method clearChatHistory*(self: Service, chatId: string) =
    try:
      let response = status_chat.deleteMessagesByChatId(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId 
        error "error while clearing chat history ", msg
        return
      
      self.events.emit(SIGNAL_CHAT_HISTORY_CLEARED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  # TODO refactor this to new object types
  method parseChatResponse*(self: Service, response: string): (seq[Chat], seq[Message]) =
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