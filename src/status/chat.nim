import eventemitter, sets, json, strutils
import sequtils
import libstatus/utils
import libstatus/chat as status_chat
import chronicles
import ../signals/types
import chat/chat_item
import chat/chat_message
import tables
export chat_item
export chat_message

type MsgArgs* = ref object of Args
    message*: string
    chatId*: string
    payload*: JsonNode

type ChannelArgs* = ref object of Args
    channel*: string
    chatTypeInt*: ChatType

type ChatArgs* = ref object of Args
  chats*: seq[Chat]

type
  ChatModel* = ref object
    events*: EventEmitter
    channels*: HashSet[string]
    filters*: Table[string, string]

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.events = events
  result.channels = initHashSet[string]()
  result.filters = initTable[string, string]()

proc delete*(self: ChatModel) =
  discard

proc hasChannel*(self: ChatModel, chatId: string): bool =
  result = self.channels.contains(chatId)

proc getActiveChannel*(self: ChatModel): string =
  if (self.channels.len == 0): "" else: self.channels.toSeq[self.channels.len - 1]

proc join*(self: ChatModel, chatId: string, chatTypeInt: ChatType, isNewChat: bool = true) =
  if self.hasChannel(chatId): return

  self.channels.incl chatId

  let generatedSymKey = status_chat.generateSymKeyFromPassword()

  # TODO get this from the connection or something
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"

  let oneToOne = isOneToOneChat(chatId)

  if isNewChat: status_chat.saveChat(chatId, oneToOne)

  let filterResult = status_chat.loadFilters(chatId = chatId, oneToOne = oneToOne)
  
  status_chat.chatMessages(chatId)

  let parsedResult = parseJson(filterResult)["result"]

  var topics = newSeq[string](0)
  for topicObj in parsedResult:
    if (($topicObj["chatId"]).strip(chars = {'"'}) == chatId):
      topics.add(($topicObj["topic"]).strip(chars = {'"'}))

    if(not self.filters.hasKey(chatId)): self.filters[chatId] = topicObj["filterId"].getStr

  if (topics.len == 0):
    warn "No topic found for the chat. Cannot load past messages"
  else:
    status_chat.requestMessages(topics, generatedSymKey, peer, 20)

  self.events.emit("channelJoined", ChannelArgs(channel: chatId, chatTypeInt: chatTypeInt))
  self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))

proc load*(self: ChatModel) =
  let chatList = status_chat.loadChats()
  for chat in chatList:
    self.join(chat.id, chat.chatType, false)
  self.events.emit("chatsLoaded", ChatArgs(chats: chatList))

proc leave*(self: ChatModel, chatId: string) =
  status_chat.removeFilters(chatId, self.filters[chatId])
  status_chat.deactivateChat(chatId)
  # TODO: REMOVE MAILSERVER TOPIC
  # TODO: REMOVE HISTORY

  self.filters.del(chatId)
  self.channels.excl(chatId)
  self.events.emit("channelLeft", ChannelArgs(channel: chatId))
  self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))

proc sendMessage*(self: ChatModel, chatId: string, msg: string): string =
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var parsedMessage = parseJson(sentMessage)["result"]["chats"][0]["lastMessage"]
  self.events.emit("messageSent", MsgArgs(message: msg, chatId: chatId, payload: parsedMessage))
  sentMessage
