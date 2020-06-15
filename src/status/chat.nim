import eventemitter, json
import sequtils
import libstatus/chat as status_chat
import ./profile as status_profile
import chronicles
import chat/[chat, message]
import ../signals/messages
import tables

type 
  ChatUpdateArgs* = ref object of Args
    chats*: seq[Chat]
    messages*: seq[Message]

  ChatIdArg* = ref object of Args
    chatId*: string

  ChannelArgs* = ref object of Args
    chat*: Chat

  ChatArgs* = ref object of Args
    chats*: seq[Chat]

  TopicArgs* = ref object of Args
    topics*: seq[string]

  MsgsLoadedArgs* = ref object of Args
    messages*: seq[Message]

  ChatModel* = ref object
    events*: EventEmitter
    channels*: Table[string, Chat]
    filters*: Table[string, string]
    msgCursor*: Table[string, string]

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.events = events
  result.channels = initTable[string, Chat]()
  result.filters = initTable[string, string]()
  result.msgCursor = initTable[string, string]()

proc delete*(self: ChatModel) =
  discard

proc update*(self: ChatModel, chats: seq[Chat], messages: seq[Message]) =
  for chat in chats:
    if chat.isActive:
      self.channels[chat.id] = chat
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats))

proc hasChannel*(self: ChatModel, chatId: string): bool =
  self.channels.hasKey(chatId)

proc getActiveChannel*(self: ChatModel): string =
  if (self.channels.len == 0): "" else: toSeq(self.channels.values)[self.channels.len - 1].id

proc join*(self: ChatModel, chatId: string, chatType: ChatType) =
  if self.hasChannel(chatId): return

  var chat = newChat(chatId, ChatType(chatType))
  self.channels[chat.id] = chat
  status_chat.saveChat(chatId, chatType.isOneToOne, true, chat.color)
  let filterResult = status_chat.loadFilters(@[status_chat.buildFilter(chat)])

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

  self.events.emit("channelJoined", ChannelArgs(chat: chat))
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: self.getActiveChannel()))

proc init*(self: ChatModel) =
  let chatList = status_chat.loadChats()

  var filters:seq[JsonNode] = @[]
  for chat in chatList:
    if self.hasChannel(chat.id): continue
    filters.add status_chat.buildFilter(chat)
    self.channels[chat.id] = chat
    self.events.emit("channelJoined", ChannelArgs(chat: chat))

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
  if self.channels[chatId].chatType == ChatType.PrivateGroupChat:
    discard status_chat.leaveGroupChat(chatId)

  # We still want to be able to receive messages unless we block the 1:1 sender
  if self.filters.hasKey(chatId) and self.channels[chatId].chatType == ChatType.Public:
    status_chat.removeFilters(chatId, self.filters[chatId])
    
  status_chat.deactivateChat(self.channels[chatId])
  # TODO: REMOVE MAILSERVER TOPIC
  # TODO: REMOVE HISTORY
  self.filters.del(chatId)
  self.channels.del(chatId)  
  self.events.emit("channelLeft", ChatIdArg(chatId: chatId))
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: ""))


proc setActiveChannel*(self: ChatModel, chatId: string) =
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: chatId))

proc formatChatUpdate(response: JsonNode): (seq[Chat], seq[Message]) =
  var chats: seq[Chat] = @[]
  var messages: seq[Message] = @[]
  if response["result"]{"chats"} != nil:
    for jsonMsg in response["result"]["messages"]:
      messages.add(jsonMsg.toMessage)
  if response["result"]{"chats"} != nil:
    for jsonChat in response["result"]["chats"]:
      chats.add(jsonChat.toChat) 
  result = (chats, messages)

proc sendMessage*(self: ChatModel, chatId: string, msg: string): string =
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var (chats, messages) = formatChatUpdate(parseJson(sentMessage))
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats))
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

proc confirmJoiningGroup*(self: ChatModel, chatId: string) =
  var response = parseJson(status_chat.confirmJoiningGroup(chatId))
  var (chats, messages) = formatChatUpdate(response)
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats))

proc blockContact*(self: ChatModel, id: string): string =
  var contact = status_profile.getContactByID(id)
  contact.systemTags.add(":contact/blocked")
  result = status_chat.blockContact(contact)

