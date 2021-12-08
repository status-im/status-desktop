import NimQml, Tables, json, sequtils, strformat, chronicles, os

import ./dto/chat as chat_dto
import ../message/dto/message as message_dto
import ../contacts/service as contact_service
import status/statusgo_backend_new/chat as status_chat
import status/statusgo_backend_new/chatCommands as status_chat_commands
import ../../../app/utils/image_utils
import ../../../constants

from ../../common/account_constants import ZERO_ADDRESS

# TODO: We need to remove these `status-lib` types from here
import status/types/[message]
import status/types/chat as chat_type

import eventemitter

export chat_dto


logScope:
  topics = "chat-service"

include ../../common/json_utils

type
  # TODO remove New when refactored
  ChatUpdateArgsNew* = ref object of Args
    chats*: seq[ChatDto]
    messages*: seq[MessageDto]
    # TODO refactor that part
    # pinnedMessages*: seq[MessageDto]
    # emojiReactions*: seq[Reaction]
    # communities*: seq[Community]
    # communityMembershipRequests*: seq[CommunityMembershipRequest]
    # activityCenterNotifications*: seq[ActivityCenterNotification]
    # statusUpdates*: seq[StatusUpdate]
    # deletedMessages*: seq[RemovedMessage]
  
  ChatArgs* = ref object of Args
    chatId*: string

  MessageSendingSuccess* = ref object of Args
    chat*: ChatDto
    message*: MessageDto

  MessageArgs* = ref object of Args
    id*: string
    channel*: string

# Events this service emits
# TODO remove new when refactor is done
const SIGNAL_CHAT_UPDATE* = "chatUpdate_new"
const SIGNAL_CHAT_LEFT* = "channelLeft_new"
const SIGNAL_SENDING_FAILED* = "messageSendingFailed_new"
const SIGNAL_SENDING_SUCCESS* = "messageSendingSuccess_new"
const SIGNAL_MESSAGE_DELETED* = "messageDeleted_new"
const SIGNAL_CHAT_MUTED* = "new-chatMuted"
const SIGNAL_CHAT_UNMUTED* = "new-chatUnmuted"
const SIGNAL_CHAT_HISTORY_CLEARED* = "new-chatHistoryCleared"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    contactService: contact_service.Service

  proc delete*(self: Service) =
    discard

  proc newService*(events: EventEmitter, contactService: contact_service.Service): Service =
    new(result, delete)
    result.events = events
    result.contactService = contactService
    result.chats = initTable[string, ChatDto]()

  proc init*(self: Service) =
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

  proc hasChannel*(self: Service, chatId: string): bool =
    self.chats.hasKey(chatId)

  # TODO refactor this to new object types
  proc parseChatResponse*(self: Service, response: string): (seq[chat_type.Chat], seq[Message]) =
    var parsedResponse = parseJson(response)
    var chats: seq[Chat] = @[]
    var messages: seq[Message] = @[]
    if parsedResponse{"result"}{"messages"} != nil:
      for jsonMsg in parsedResponse["result"]["messages"]:
        messages.add(jsonMsg.toMessage())
    if parsedResponse{"result"}{"chats"} != nil:
      for jsonChat in parsedResponse["result"]["chats"]:
        let chat = chat_type.toChat(jsonChat)
        # TODO add the channel back to `chat` when it is refactored
        # self.channels[chat.id] = chat
        chats.add(chat) 
    result = (chats, messages)

  # TODO refactor this to new object types
  proc parseChatResponse2*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) =
    var chats: seq[ChatDto] = @[]
    var messages: seq[MessageDto] = @[]
    if response.result{"messages"} != nil:
      for jsonMsg in response.result["messages"]:
        messages.add(jsonMsg.toMessageDto)
    if response.result{"chats"} != nil:
      for jsonChat in response.result["chats"]:
        let chat = chat_dto.toChatDto(jsonChat)
        # TODO add the channel back to `chat` when it is refactored
        self.chats[chat.id] = chat
        chats.add(chat) 
    result = (chats, messages)

  proc processMessageUpdateAfterSend(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto])  =
    result = self.parseChatResponse2(response)
    var (chats, messages) = result
    if chats.len == 0 and messages.len == 0:
      self.events.emit(SIGNAL_SENDING_FAILED, Args())
      return

    # This fixes issue#3490
    var msg = messages[0]
    for m in messages:
      if(m.responseTo.len > 0):
        msg = m
        break
    
    self.events.emit(SIGNAL_SENDING_SUCCESS, MessageSendingSuccess(message: msg, chat: chats[0]))

  proc processUpdateForTransaction*(self: Service, messageId: string, response: RpcResponse[JsonNode]) =
    var (chats, messages) = self.processMessageUpdateAfterSend(response)
    self.events.emit(SIGNAL_MESSAGE_DELETED, MessageArgs(id: messageId, channel: chats[0].id))

  proc emitUpdate(self: Service, response: RpcResponse[JsonNode]) =
    var (chats, messages) = self.parseChatResponse2(response)
    self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgsNew(messages: messages, chats: chats))

  proc getAllChats*(self: Service): seq[ChatDto] =
    return toSeq(self.chats.values)

  proc getChatsOfChatTypes*(self: Service, types: seq[chat_dto.ChatType]): seq[ChatDto] =
    return self.getAllChats().filterIt(it.chatType in types)

  proc getChatById*(self: Service, chatId: string): ChatDto =
    if(not self.chats.contains(chatId)):
      error "trying to get chat data for an unexisting chat id"
      return

    return self.chats[chatId]

  proc getOneToOneChatNameAndImage*(self: Service, chatId: string): 
    tuple[name: string, image: string, isIdenticon: bool] =
    return self.contactService.getContactNameAndImage(chatId)

  proc createChatFromResponse(self: Service, response: RpcResponse[JsonNode]): tuple[chatDto: ChatDto, success: bool] =
    var jsonArr: JsonNode
    if (not response.result.getProp("chats", jsonArr)):
      error "error: response of creating chat doesn't contain created chats"
      result.success = false
      return

    let chats = map(jsonArr.getElems(), proc(x: JsonNode): ChatDto = x.toChatDto())
    # created chat is returned as the first elemnt of json array (it's up to `status-go`)
    if(chats.len == 0):
      error "error: unknown error occured creating chat"
      result.success = false
      return

    result.chatDto = chats[0]
    result.success = true

  proc createPublicChat*(self: Service, chatId: string): tuple[chatDto: ChatDto, success: bool] =
    try:
      let response = status_chat.createPublicChat(chatId)
      result = self.createChatFromResponse(response)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc createOneToOneChat*(self: Service, chatId: string, ensName: string): tuple[chatDto: ChatDto, success: bool] =
    try:
      if self.hasChannel(chatId):
        # We want to show the chat to the user and for that we activate the chat
        discard status_chat.saveChat(
          chatId,
          chat_dto.ChatType.OneToOne.int,
          color=self.chats[chatId].color,
          ensName=ensName)
        result.success = true
        result.chatDto = self.chats[chatId]
        return

      let response =  status_chat.createOneToOneChat(chatId)
      result = self.createChatFromResponse(response)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc leaveChat*(self: Service, chatId: string): bool =
    try:
      if self.chats.len == 0:
        return false
      if(not self.chats.contains(chatId)):
        error "trying to leave chat for an unexisting chat id", chatId
        return false

      let chat = self.chats[chatId]
      if chat.chatType == chat_dto.ChatType.PrivateGroupChat:
        let leaveGroupResponse = status_chat.leaveGroupChat(chatId)
        self.emitUpdate(leaveGroupResponse)

      discard status_chat.deactivateChat(chatId)

      self.chats.del(chatId)
      discard status_chat.clearChatHistory(chatId)
      self.events.emit(SIGNAL_CHAT_LEFT, ChatArgs(chatId: chatId))
      return true
    except Exception as e:
      error "Error deleting channel", chatId, msg = e.msg
      return false
    
  proc sendImages*(self: Service, chatId: string, imagePathsJson: string): string =
    result = ""
    try:
      var images = Json.decode(imagePathsJson, seq[string])

      for imagePath in images.mitems:
        var image = image_utils.formatImagePath(imagePath)
        imagePath = image_resizer(image, 2000, TMPDIR)

      discard status_chat.sendImages(chatId, images)

      for imagePath in images.items:
        removeFile(imagePath)
    except Exception as e:
      error "Error sending images", msg = e.msg
      result = fmt"Error sending images: {e.msg}"

  proc requestAddressForTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response =  status_chat_commands.requestAddressForTransaction(chatId, fromAddress, amount, address)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting address for transaction", msg = e.msg

  proc requestTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response = status_chat_commands.requestTransaction(chatId, fromAddress, amount, address)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc declineRequestTransaction*(self: Service, messageId: string) =
    try:
      let response = status_chat_commands.declineRequestTransaction(messageId)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc declineRequestAddressForTransaction*(self: Service, messageId: string) =
    try:
      let response = status_chat_commands.declineRequestAddressForTransaction(messageId)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc acceptRequestAddressForTransaction*(self: Service, messageId: string, address: string) =
    try:
      let response = status_chat_commands.acceptRequestAddressForTransaction(messageId, address)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc acceptRequestTransaction*(self: Service, transactionHash: string, messageId: string, signature: string) =
    try:
      let response = status_chat_commands.acceptRequestTransaction(transactionHash, messageId, signature)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc muteChat*(self: Service, chatId: string) =
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

  proc unmuteChat*(self: Service, chatId: string) =
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
