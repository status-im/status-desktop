import eventemitter, json, strutils, sequtils, tables, chronicles, sugar
import libstatus/settings as status_settings
import libstatus/chat as status_chat
import libstatus/stickers as status_stickers
import libstatus/types
import profile/profile
import chat/[chat, message]
import ../signals/messages
import ens
import eth/common/eth_types

logScope:
  topics = "chat-model"

type 
  ChatUpdateArgs* = ref object of Args
    chats*: seq[Chat]
    messages*: seq[Message]
    contacts*: seq[Profile]

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
    contacts*: Table[string, Profile]
    channels*: Table[string, Chat]
    msgCursor*: Table[string, string]
    recentStickers*: seq[Sticker]
    availableStickerPacks*: Table[int, StickerPack]
    installedStickerPacks*: Table[int, StickerPack]
    purchasedStickerPacks*: seq[int]
    
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
  result.recentStickers = @[]
  result.availableStickerPacks = initTable[int, StickerPack]()
  result.installedStickerPacks = initTable[int, StickerPack]()
  result.purchasedStickerPacks = @[]


proc delete*(self: ChatModel) =
  discard

proc update*(self: ChatModel, chats: seq[Chat], messages: seq[Message]) =
  for chat in chats:
    if chat.isActive:
      self.channels[chat.id] = chat

  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))

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

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.emit("mailserverTopics", TopicArgs(topics: topics));

  self.events.emit("channelJoined", ChannelArgs(chat: chat))

proc getPurchasedStickerPacks*(self: ChatModel, address: EthAddress): seq[int] =
  if self.purchasedStickerPacks != @[]:
    return self.purchasedStickerPacks

  try:
    # Buy the "Toozeman" sticker pack on testnet
    # Ensure there is enough STT and ETHro in the account first before uncommenting.
    # STT faucet: simpledapp.eth
    # NOTE: don't forget to update your account password!
    # if status_settings.getCurrentNetwork() == Network.Testnet:
    #   debugEcho ">>> [getPurchasedStickerPacks] buy Toozeman sticker pack, response/txid: ", status_stickers.buyPack(1.u256, address, "20000000000000000000".u256, "<your password here>")
    var
      balance = status_stickers.getBalance(address)
      tokenIds = toSeq[0..<balance].map(idx => status_stickers.tokenOfOwnerByIndex(address, idx.u256))

    self.purchasedStickerPacks = tokenIds.map(tokenId => status_stickers.getPackIdFromTokenId(tokenId.u256))
    result = self.purchasedStickerPacks
  except RpcException:
    error "Error getting purchased sticker packs", message = getCurrentExceptionMsg()
    result = @[]

proc getInstalledStickerPacks*(self: ChatModel): Table[int, StickerPack] =
  if self.installedStickerPacks != initTable[int, StickerPack]():
    return self.installedStickerPacks

  self.installedStickerPacks = status_stickers.getInstalledStickerPacks()
  result = self.installedStickerPacks

proc getAvailableStickerPacks*(self: ChatModel): Table[int, StickerPack] =
  if self.availableStickerPacks != initTable[int, StickerPack]():
    return self.availableStickerPacks

  try: 
    let numPacks = status_stickers.getPackCount()
    for i in 0..<numPacks:
      try:
        let stickerPack = status_stickers.getPackData(i.u256)
        self.availableStickerPacks[stickerPack.id] = stickerPack
      except:
        continue
    result = self.availableStickerPacks
  except RpcException:
    error "Error in getAvailableStickerPacks", message = getCurrentExceptionMsg()
    result = initTable[int, StickerPack]()

proc getRecentStickers*(self: ChatModel): seq[Sticker] =
  result = status_stickers.getRecentStickers()

proc installStickerPack*(self: ChatModel, packId: int) =
  if not self.availableStickerPacks.hasKey(packId):
    return
  let pack = self.availableStickerPacks[packId]
  self.installedStickerPacks[packId] = pack
  status_stickers.saveInstalledStickerPacks(self.installedStickerPacks)

proc removeRecentStickers*(self: ChatModel, packId: int) =
  self.recentStickers.keepItIf(it.packId != packId)
  status_stickers.saveRecentStickers(self.recentStickers)

proc uninstallStickerPack*(self: ChatModel, packId: int) =
  if not self.installedStickerPacks.hasKey(packId):
    return
  let pack = self.availableStickerPacks[packId]
  self.installedStickerPacks.del(packId)
  status_stickers.saveInstalledStickerPacks(self.installedStickerPacks)

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

  var topics:seq[string] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for topicObj in parsedResult:
    # Only add topics for chats the user has joined
    let topic_chat = topicObj["chatId"].getStr
    if self.channels.hasKey(topic_chat) and self.channels[topic_chat].isActive:
      topics.add($topicObj["topic"].getStr)

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.emit("mailserverTopics", TopicArgs(topics: topics));

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
  

proc setActiveChannel*(self: ChatModel, chatId: string) =
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: chatId))

proc sendMessage*(self: ChatModel, chatId: string, msg: string, replyTo: string = "", contentType: int = ContentType.Message.int) =
  var response = status_chat.sendChatMessage(chatId, msg, replyTo, contentType)
  var (chats, messages) = self.processChatUpdate(parseJson(response))
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
  for msg in messages:
    self.events.emit("sendingMessage", MessageArgs(id: msg.id, channel: msg.chatId))

proc sendImage*(self: ChatModel, chatId: string, image: string) =
  var response = status_chat.sendImageMessage(chatId, image)
  var (chats, messages) = self.processChatUpdate(parseJson(response))
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
  for msg in messages:
    self.events.emit("sendingMessage", MessageArgs(id: msg.id, channel: msg.chatId))

proc addStickerToRecent*(self: ChatModel, sticker: Sticker, save: bool = false) =
  self.recentStickers.insert(sticker, 0)
  self.recentStickers = self.recentStickers.deduplicate()
  if self.recentStickers.len > 24:
    self.recentStickers = self.recentStickers[0..23] # take top 24 most recent
  if save:
    status_stickers.saveRecentStickers(self.recentStickers)

proc sendSticker*(self: ChatModel, chatId: string, sticker: Sticker) =
  var response = status_chat.sendStickerMessage(chatId, sticker)
  self.addStickerToRecent(sticker, save = true)
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
  self.events.emit("messagesLoaded", MsgsLoadedArgs(messages: messageTuple[1]))

proc markAllChannelMessagesRead*(self: ChatModel, chatId: string): JsonNode =
  var response = status_chat.markAllRead(chatId)
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

proc updateContacts*(self: ChatModel, contacts: seq[Profile]) =
  for c in contacts:
    self.contacts[c.id] = c
  self.events.emit("chatUpdate", ChatUpdateArgs(contacts: contacts))

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