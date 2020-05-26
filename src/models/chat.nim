import eventemitter, sets, json, strutils
import ../status/utils
import ../status/chat as status_chat
import chronicles
import ../status/libstatus

import chat/chat_item
import chat/chat_message
export chat_item
export chat_message

type MsgArgs* = ref object of Args
    message*: string
    chatId*: string
    payload*: JsonNode

type
  ChatModel* = ref object
    events*: EventEmitter
    channels*: HashSet[string]

proc newChatModel*(): ChatModel =
  result = ChatModel()
  result.events = createEventEmitter()
  result.channels = initHashSet[string]()

proc delete*(self: ChatModel) =
  discard

proc hasChannel*(self: ChatModel, chatId: string): bool =
  result = self.channels.contains(chatId)

proc join*(self: ChatModel, chatId: string) =
  if self.hasChannel(chatId): return

  self.channels.incl chatId

  let generatedSymKey = status_chat.generateSymKeyFromPassword()

  # TODO get this from the connection or something
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"

  # TODO: save chat list in the db
  let oneToOne = isOneToOneChat(chatId)

  let filterResult = status_chat.loadFilters(chatId = chatId, oneToOne = oneToOne)
  status_chat.saveChat(chatId, oneToOne)
  status_chat.chatMessages(chatId)

  let parsedResult = parseJson(filterResult)["result"]
  echo parsedResult
  var topics = newSeq[string](0)
  for topicObj in parsedResult:
    if (($topicObj["chatId"]).strip(chars = {'"'}) == chatId):
      topics.add(($topicObj["topic"]).strip(chars = {'"'}))

  if (topics.len == 0):
    warn "No topic found for the chat. Cannot load past messages"
  else:
    status_chat.requestMessages(topics, generatedSymKey, peer, 20)

proc leave*(self: ChatModel, chatId: string) =
  let oneToOne = isOneToOneChat(chatId)
  discard status_chat.removeFilters(chatId = chatId, oneToOne = oneToOne)
  # TODO: other calls (if any)
  self.channels.excl(chatId)

proc sendMessage*(self: ChatModel, chatId: string, msg: string): string =
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var parsedMessage = parseJson(sentMessage)["result"]["chats"][0]["lastMessage"]
  self.events.emit("messageSent", MsgArgs(message: msg, chatId: chatId, payload: parsedMessage))
  sentMessage
