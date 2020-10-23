import json, strutils, sequtils, tables, chronicles, times
import libstatus/chat as status_chat
import libstatus/mailservers as status_mailservers
import libstatus/chatCommands as status_chat_commands
import libstatus/accounts/constants as constants
import libstatus/types
import stickers
import ../eventemitter

import profile/profile
import contacts
import chat/[chat, message]
import signals/messages
import ens

logScope:
  topics = "chat-model"

type 
  ChatUpdateArgs* = ref object of Args
    chats*: seq[Chat]
    messages*: seq[Message]
    contacts*: seq[Profile]
    emojiReactions*: seq[Reaction]

  ChatIdArg* = ref object of Args
    chatId*: string

  ChannelArgs* = ref object of Args
    chat*: Chat

  ChatArgs* = ref object of Args
    chats*: seq[Chat]

  TopicArgs* = ref object of Args
    topics*: seq[MailserverTopic]

  MsgsLoadedArgs* = ref object of Args
    messages*: seq[Message]

  ReactionsLoadedArgs* = ref object of Args
    reactions*: seq[Reaction]

  ChatModel* = ref object
    events*: EventEmitter
    contacts*: Table[string, Profile]
    channels*: Table[string, Chat]
    msgCursor*: Table[string, string]
    emojiCursor*: Table[string, string]
    lastMessageTimestamps*: Table[string, int64]
    
  MessageArgs* = ref object of Args
    id*: string
    channel*: string

include chat/utils

proc newChatModel*(events: EventEmitter): ChatModel =
  result = ChatModel()
  result.events = events
  result.contacts = initTable[string, Profile]()
  result.channels = initTable[string, Chat]()
  result.msgCursor = initTable[string, string]()
  result.emojiCursor = initTable[string, string]()
  result.lastMessageTimestamps = initTable[string, int64]()

proc delete*(self: ChatModel) =
  discard

proc update*(self: ChatModel, chats: seq[Chat], messages: seq[Message], emojiReactions: seq[Reaction]) =
  for chat in chats:
    if chat.isActive:
      self.channels[chat.id] = chat

  for message in messages:
    let chatId = message.chatId
    let ts = times.convert(Milliseconds, Seconds, message.whisperTimestamp.parseInt())
    if not self.lastMessageTimestamps.hasKey(chatId):
      self.lastMessageTimestamps[chatId] = ts
    else:
      if self.lastMessageTimestamps[chatId] > ts:
        self.lastMessageTimestamps[chatId] = ts
      
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[], emojiReactions: emojiReactions))

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

  var topics:seq[MailserverTopic] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for topicObj in parsedResult:
    if ($topicObj["chatId"].getStr == chatId):
      topics.add(MailserverTopic(
        topic: $topicObj["topic"].getStr,
        discovery: topicObj["discovery"].getBool,
        negotiated: topicObj["negotiated"].getBool,
        chatIds: @[chatId],
        lastRequest: 1
      ))

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.emit("mailserverTopics", TopicArgs(topics: topics));

  self.events.emit("channelJoined", ChannelArgs(chat: chat))

proc updateContacts*(self: ChatModel, contacts: seq[Profile]) =
  for c in contacts:
    self.contacts[c.id] = c
  self.events.emit("chatUpdate", ChatUpdateArgs(contacts: contacts))

proc init*(self: ChatModel) =
  let chatList = status_chat.loadChats()

  var filters:seq[JsonNode] = @[]
  for chat in chatList:
    if self.hasChannel(chat.id): continue
    filters.add status_chat.buildFilter(chat)
    self.channels[chat.id] = chat
    self.events.emit("channelLoaded", ChannelArgs(chat: chat))

  if filters.len == 0: return

  let filterResult = status_chat.loadFilters(filters)

  self.events.emit("chatsLoaded", ChatArgs(chats: chatList))

  var topics:seq[MailserverTopic] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for topicObj in parsedResult:
    # Only add topics for chats the user has joined
    let topic_chat = topicObj["chatId"].getStr
    if self.channels.hasKey(topic_chat) and self.channels[topic_chat].isActive:
      
      topics.add(MailserverTopic(
        topic: $topicObj["topic"].getStr,
        discovery: topicObj["discovery"].getBool,
        negotiated: topicObj["negotiated"].getBool,
        chatIds: @[self.channels[topic_chat].id],
        lastRequest: 1
      ))

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.once("mailserverAvailable") do(a: Args):
      self.events.emit("mailserverTopics", TopicArgs(topics: topics));

  self.events.on("contactUpdate") do(a: Args):
    var evArgs = ContactUpdateArgs(a)
    self.updateContacts(evArgs.contacts)

proc leave*(self: ChatModel, chatId: string) =
  self.removeChatFilters(chatId)

  if self.channels[chatId].chatType == ChatType.PrivateGroupChat:
    let leaveGroupResponse = status_chat.leaveGroupChat(chatId)
    self.emitUpdate(leaveGroupResponse)

  status_chat.deactivateChat(self.channels[chatId])

  # TODO: REMOVE MAILSERVER TOPIC
  self.channels.del(chatId)
  discard status_chat.clearChatHistory(chatId)
  self.events.emit("channelLeft", ChatIdArg(chatId: chatId))
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: ""))

proc clearHistory*(self: ChatModel, chatId: string) =
  discard status_chat.clearChatHistory(chatId)
  let chat = self.channels[chatId]
  self.events.emit("chatHistoryCleared", ChannelArgs(chat: chat))

proc getLinkPreviewData*(self: ChatModel, link: string): JsonNode =
  result = status_chat.getLinkPreviewData(link)

proc setActiveChannel*(self: ChatModel, chatId: string) =
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: chatId))

proc processMessageUpdateAfterSend(self: ChatModel, response: string): (seq[Chat], seq[Message])  =
  result = self.processChatUpdate(parseJson(response))
  var (chats, messages) = result
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
  for msg in messages:
    self.events.emit("sendingMessage", MessageArgs(id: msg.id, channel: msg.chatId))

proc sendMessage*(self: ChatModel, chatId: string, msg: string, replyTo: string = "", contentType: int = ContentType.Message.int) =
  var response = status_chat.sendChatMessage(chatId, msg, replyTo, contentType)
  discard self.processMessageUpdateAfterSend(response)

proc sendImage*(self: ChatModel, chatId: string, image: string) =
  var response = status_chat.sendImageMessage(chatId, image)
  discard self.processMessageUpdateAfterSend(response)

proc sendSticker*(self: ChatModel, chatId: string, sticker: Sticker) =
  var response = status_chat.sendStickerMessage(chatId, sticker)
  self.events.emit("stickerSent", StickerArgs(sticker: sticker, save: true))
  var (chats, messages) = self.processChatUpdate(parseJson(response))
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
  self.events.emit("sendingMessage", MessageArgs(id: messages[0].id, channel: messages[0].chatId))

proc chatMessages*(self: ChatModel, chatId: string, initialLoad:bool = true) =
  if not self.msgCursor.hasKey(chatId):
    self.msgCursor[chatId] = "";

  # Messages were already loaded, since cursor will 
  # be nil/empty if there are no more messages
  if(not initialLoad and self.msgCursor[chatId] == ""): return

  let messageTuple = status_chat.chatMessages(chatId, self.msgCursor[chatId])
  self.msgCursor[chatId] = messageTuple[0];

  if messageTuple[1].len > 0:
    let lastMsgIndex = messageTuple[1].len - 1
    let ts = times.convert(Milliseconds, Seconds, messageTuple[1][lastMsgIndex].whisperTimestamp.parseInt())
    self.lastMessageTimestamps[chatId] = ts

  self.events.emit("messagesLoaded", MsgsLoadedArgs(messages: messageTuple[1]))

proc chatReactions*(self: ChatModel, chatId: string, initialLoad:bool = true) =
  try:
    if not self.emojiCursor.hasKey(chatId):
      self.emojiCursor[chatId] = "";

    # Messages were already loaded, since cursor will 
    # be nil/empty if there are no more messages
    if(not initialLoad and self.emojiCursor[chatId] == ""): return

    let reactionTuple = status_chat.getEmojiReactionsByChatId(chatId, self.emojiCursor[chatId])
    self.emojiCursor[chatId] = reactionTuple[0];
    self.events.emit("reactionsLoaded", ReactionsLoadedArgs(reactions: reactionTuple[1]))
  except Exception as e:
    error "Error reactions", msg = e.msg
  
proc addEmojiReaction*(self: ChatModel, chatId: string, messageId: string, emojiId: int) =
  let reactions = status_chat.addEmojiReaction(chatId, messageId, emojiId)
  self.events.emit("reactionsLoaded", ReactionsLoadedArgs(reactions: reactions))

proc removeEmojiReaction*(self: ChatModel, emojiReactionId: string) =
  let reactions = status_chat.removeEmojiReaction(emojiReactionId)
  self.events.emit("reactionsLoaded", ReactionsLoadedArgs(reactions: reactions))

proc markAllChannelMessagesRead*(self: ChatModel, chatId: string): JsonNode =
  var response = status_chat.markAllRead(chatId)
  result = parseJson(response)
  if self.channels.hasKey(chatId):
    self.channels[chatId].unviewedMessagesCount = 0
    self.events.emit("channelUpdate", ChatUpdateArgs(messages: @[], chats: @[self.channels[chatId]], contacts: @[]))

proc markMessagesSeen*(self: ChatModel, chatId: string, messageIds: seq[string]): JsonNode =
  var response = status_chat.markMessagesSeen(chatId, messageIds)
  result = parseJson(response)
  if self.channels.hasKey(chatId):
    self.channels[chatId].unviewedMessagesCount = 0
    self.events.emit("channelUpdate", ChatUpdateArgs(messages: @[], chats: @[self.channels[chatId]], contacts: @[]))

proc confirmJoiningGroup*(self: ChatModel, chatId: string) =
    var response = status_chat.confirmJoiningGroup(chatId)
    self.emitUpdate(response)

proc renameGroup*(self: ChatModel, chatId: string, newName: string) =
  var response = status_chat.renameGroup(chatId, newName)
  self.emitUpdate(response)

proc getUserName*(self: ChatModel, id: string, defaultUserName: string):string =
  if(self.contacts.hasKey(id)):
    return userNameOrAlias(self.contacts[id])
  else:
    return defaultUserName

proc createGroup*(self: ChatModel, groupName: string, pubKeys: seq[string]) =
  var response = parseJson(status_chat.createGroup(groupName, pubKeys))
  var (chats, messages) = formatChatUpdate(response)
  let chat = chats[0]
  self.channels[chat.id] = chat
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: chat.id))

proc addGroupMembers*(self: ChatModel, chatId: string, pubKeys: seq[string]) =
  var response = status_chat.addGroupMembers(chatId, pubKeys)
  self.emitUpdate(response)

proc kickGroupMember*(self: ChatModel, chatId: string, pubKey: string) =
  var response = status_chat.kickGroupMember(chatId, pubKey)
  self.emitUpdate(response)

proc makeAdmin*(self: ChatModel, chatId: string, pubKey: string) =
  var response = status_chat.makeAdmin(chatId, pubKey)
  self.emitUpdate(response)

proc resendMessage*(self: ChatModel, messageId: string) =
  discard status_chat.reSendChatMessage(messageId)

proc muteChat*(self: ChatModel, chatId: string) =
  discard status_chat.muteChat(chatId)

proc unmuteChat*(self: ChatModel, chatId: string) =
  discard status_chat.unmuteChat(chatId)

proc processUpdateForTransaction*(self: ChatModel, messageId: string, response: string) =
  var (chats, messages) = self.processMessageUpdateAfterSend(response)
  self.events.emit("messageDeleted", MessageArgs(id: messageId, channel: chats[0].id))

proc acceptRequestAddressForTransaction*(self: ChatModel, messageId: string, address: string) =
  let response = status_chat_commands.acceptRequestAddressForTransaction(messageId, address)
  self.processUpdateForTransaction(messageId, response)

proc declineRequestAddressForTransaction*(self: ChatModel, messageId: string) =
  let response = status_chat_commands.declineRequestAddressForTransaction(messageId)
  self.processUpdateForTransaction(messageId, response)

proc declineRequestTransaction*(self: ChatModel, messageId: string) =
  let response = status_chat_commands.declineRequestTransaction(messageId)
  self.processUpdateForTransaction(messageId, response)

proc requestAddressForTransaction*(self: ChatModel, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  let address = if (tokenAddress == constants.ZERO_ADDRESS): "" else: tokenAddress
  let response = status_chat_commands.requestAddressForTransaction(chatId, fromAddress, amount, address)
  discard self.processMessageUpdateAfterSend(response)

proc requestTransaction*(self: ChatModel, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
  let address = if (tokenAddress == constants.ZERO_ADDRESS): "" else: tokenAddress
  let response = status_chat_commands.requestTransaction(chatId, fromAddress, amount, address)
  discard self.processMessageUpdateAfterSend(response)
