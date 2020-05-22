import eventemitter, sets
import json, sets, eventemitter
import ../status/utils
import ../status/chat as status_chat

type MsgArgs* = ref object of Args
    message*: string
    chatId*: string
    payload*: JsonNode

type
  ChatModel* = ref object
    events*: EventEmitter
    channels*: HashSet[string]

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.channels = initHashSet[string]()
  result.events = events

proc delete*(self: ChatModel) =
  discard

proc hasChannel*(self: ChatModel, chatId: string): bool =
  result = self.channels.contains(chatId)

proc join*(self: ChatModel, chatId: string) =
  if self.hasChannel(chatId): return

  self.channels.incl chatId

  # TODO: save chat list in the db

  let oneToOne = isOneToOneChat(chatId)

  status_chat.loadFilters(chatId, oneToOne)
  status_chat.saveChat(chatId, oneToOne)
  status_chat.chatMessages(chatId)

proc sendMessage*(self: ChatModel, chatId: string, msg: string): string =
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var parsedMessage = parseJson(sentMessage)["result"]["chats"][0]["lastMessage"]
  self.events.emit("messageSent", MsgArgs(message: msg, chatId: chatId, payload: parsedMessage))
  sentMessage
