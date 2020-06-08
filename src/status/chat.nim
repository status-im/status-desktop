import eventemitter, sets, json
import sequtils
import libstatus/chat as status_chat
import chronicles
import ../signals/types
import chat/chat_item
import chat/chat_message
import tables

export chat_item
export chat_message

type 
  MsgArgs* = ref object of Args
    message*: string
    chatId*: string
    payload*: JsonNode

  ChannelArgs* = ref object of Args
    channel*: string
    chatTypeInt*: ChatType

  ChatArgs* = ref object of Args
    chats*: seq[Chat]

  TopicArgs* = ref object of Args
    topics*: seq[string]

  MsgsLoadedArgs* = ref object of Args
    messages*: seq[Message]

  ChatModel* = ref object
    events*: EventEmitter
    channels*: HashSet[string]
    filters*: Table[string, string]
    msgCursor*: Table[string, string]

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.events = events
  result.channels = initHashSet[string]()
  result.filters = initTable[string, string]()
  result.msgCursor = initTable[string, string]()

proc delete*(self: ChatModel) =
  discard

proc hasChannel*(self: ChatModel, chatId: string): bool =
  result = self.channels.contains(chatId)

proc getActiveChannel*(self: ChatModel): string =
  if (self.channels.len == 0): "" else: self.channels.toSeq[self.channels.len - 1]

proc join*(self: ChatModel, chatId: string, chatType: ChatType) =
  if self.hasChannel(chatId): return
  self.channels.incl chatId
  status_chat.saveChat(chatId, chatType.isOneToOne)
  let filterResult = status_chat.loadFilters(@[status_chat.buildFilter(chatId = chatId, oneToOne = chatType.isOneToOne)])

  var topics:seq[string] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for topicObj in parsedResult:
    if ($topicObj["chatId"].getStr == chatId):
      topics.add($topicObj["topic"].getStr)
      if(not self.filters.hasKey(chatId)): self.filters[chatId] = topicObj["filterId"].getStr

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.emit("mailserverTopics", TopicArgs(topics: topics));

  self.events.emit("channelJoined", ChannelArgs(channel: chatId, chatTypeInt: chatType))
  self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))

proc init*(self: ChatModel) =
  let chatList = status_chat.loadChats()

  var filters:seq[JsonNode] = @[]
  for chat in chatList:
    if self.hasChannel(chat.id): continue
    filters.add status_chat.buildFilter(chatId = chat.id, oneToOne = chat.chatType.isOneToOne)
    self.channels.incl chat.id
    self.events.emit("channelJoined", ChannelArgs(channel: chat.id, chatTypeInt: chat.chatType))

  if filters.len == 0: return

  let filterResult = status_chat.loadFilters(filters)

  self.events.emit("chatsLoaded", ChatArgs(chats: chatList))

  var topics:seq[string] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for topicObj in parsedResult:
    topics.add($topicObj["topic"].getStr)
    self.filters[$topicObj["chatId"].getStr] = topicObj["filterId"].getStr

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.emit("mailserverTopics", TopicArgs(topics: topics));
  
proc leave*(self: ChatModel, chatId: string) =
  status_chat.removeFilters(chatId, self.filters[chatId])
  status_chat.deactivateChat(chatId)
  # TODO: REMOVE MAILSERVER TOPIC
  # TODO: REMOVE HISTORY

  self.filters.del(chatId)
  self.channels.excl(chatId)
  self.events.emit("channelLeft", ChannelArgs(channel: chatId))
  self.events.emit("activeChannelChanged", ChannelArgs(channel: self.getActiveChannel()))

proc setActiveChannel*(self: ChatModel, chatId: string) =
  self.events.emit("activeChannelChanged", ChannelArgs(channel: chatId))

proc sendMessage*(self: ChatModel, chatId: string, msg: string): string =
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var parsedMessage = parseJson(sentMessage)["result"]["chats"][0]["lastMessage"]
  self.events.emit("messageSent", MsgArgs(message: msg, chatId: chatId, payload: parsedMessage))
  sentMessage

proc chatMessages*(self: ChatModel, chatId: string, initialLoad:bool = true) =
  if not self.msgCursor.hasKey(chatId):
    self.msgCursor[chatId] = "";

  # Messages were already loaded, since cursor will 
  # be nil/empty if there are no more messages
  if(not initialLoad and self.msgCursor[chatId] == ""): return

  let messageTuple = status_chat.chatMessages(chatId, self.msgCursor[chatId])
  self.msgCursor[chatId] = messageTuple[0];
  self.events.emit("messagesLoaded", MsgsLoadedArgs(messages: messageTuple[1]))

proc markAllChannelMessagesRead*(self: ChatModel, chatId: string): JsonNode =
  var response = status_chat.markAllRead(chatId)
  result = parseJson(response)
