import eventemitter, sets, json, strutils
import sequtils
import libstatus/utils
import libstatus/core as status_core
import libstatus/chat as status_chat
import libstatus/mailservers as status_mailservers
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

proc join*(self: ChatModel, chatId: string, chatType: ChatType) =
  if self.hasChannel(chatId): return

  self.channels.incl chatId

  let generatedSymKey = status_chat.generateSymKeyFromPassword()

  #TODO get this from the connection or something
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"

  status_chat.saveChat(chatId, chatType.isOneToOne)
  let filterResult = status_chat.loadFilters(@[status_chat.buildFilter(chatId = chatId, oneToOne = chatType.isOneToOne)])

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

  self.events.emit("channelJoined", ChannelArgs(channel: chatId, chatTypeInt: chatType))
  self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))
  

proc init*(self: ChatModel) =
  let chatList = status_chat.loadChats()
  let generatedSymKey = status_chat.generateSymKeyFromPassword()

  let peer = "enode://c42f368a23fa98ee546fd247220759062323249ef657d26d357a777443aec04db1b29a3a22ef3e7c548e18493ddaf51a31b0aed6079bd6ebe5ae838fcfaf3a49@178.128.142.54:443"
  # TODO this is needed for now for the retrieving of past messages. We'll either move or remove it later
  status_core.addPeer(peer)

  var filters:seq[JsonNode] = @[]
  for chat in chatList:
    if self.hasChannel(chat.id): continue
    filters.add status_chat.buildFilter(chatId = chat.id, oneToOne = chat.chatType.isOneToOne)
    self.channels.incl chat.id
    self.events.emit("channelJoined", ChannelArgs(channel: chat.id, chatTypeInt: chat.chatType))
    self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))

  if filters.len == 0: return

  let filterResult = status_chat.loadFilters(filters)

  self.events.emit("chatsLoaded", ChatArgs(chats: chatList))

  let parsedResult = parseJson(filterResult)["result"]
  var topics = newSeq[string](0)
  for topicObj in parsedResult:
    topics.add($topicObj["topic"].getStr)
    self.filters[$topicObj["chatId"].getStr] = topicObj["filterId"].getStr

  if (topics.len == 0):
    warn "No topic found for the chat. Cannot load past messages"
  else:
    status_chat.requestMessages(topics, generatedSymKey, peer, 20)
  

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
