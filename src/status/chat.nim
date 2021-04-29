import json, strutils, sequtils, tables, chronicles, times, sugar
import libstatus/chat as status_chat
import libstatus/mailservers as status_mailservers
import libstatus/chatCommands as status_chat_commands
import libstatus/accounts/constants as constants
import libstatus/types
import libstatus/utils as status_utils
import libstatus/contacts as status_contacts
import stickers
import ../eventemitter

import profile/profile
import contacts
import chat/[chat, message]
import signals/messages
import ens

logScope:
  topics = "chat-model"

const backToFirstChat* = "__goBackToFirstChat"

type 
  ChatUpdateArgs* = ref object of Args
    chats*: seq[Chat]
    messages*: seq[Message]
    contacts*: seq[Profile]
    emojiReactions*: seq[Reaction]
    communities*: seq[Community]
    communityMembershipRequests*: seq[CommunityMembershipRequest]

  ChatIdArg* = ref object of Args
    chatId*: string

  ChannelArgs* = ref object of Args
    chat*: Chat

  ChatArgs* = ref object of Args
    chats*: seq[Chat]
  
  CommunityActiveChangedArgs* = ref object of Args
    active*: bool

  TopicArgs* = ref object of Args
    topics*: seq[MailserverTopic]

  MsgsLoadedArgs* = ref object of Args
    messages*: seq[Message]

  ReactionsLoadedArgs* = ref object of Args
    reactions*: seq[Reaction]

  ChatModel* = ref object
    publicKey*: string
    events*: EventEmitter
    communitiesToFetch*: seq[string]
    mailserverReady*: bool
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
  result.mailserverReady = false
  result.communitiesToFetch = @[]
  result.contacts = initTable[string, Profile]()
  result.channels = initTable[string, Chat]()
  result.msgCursor = initTable[string, string]()
  result.emojiCursor = initTable[string, string]()
  result.lastMessageTimestamps = initTable[string, int64]()

proc delete*(self: ChatModel) =
  discard

proc cleanSpamChatGroups(self: ChatModel, chats: seq[Chat], contacts: seq[Profile]): seq[Chat] =
  for chat in chats:
    if not chat.isActive: continue
    if chat.chatType == ChatType.PrivateGroupChat:
      var isContact = false
      var joined = false
      for member in chat.members:
        if member.id == self.publicKey and member.joined:
          joined = true
        if member.admin and member.joined:
          for contact in contacts:
            if contact.address == member.id:
              isContact = true
      if not isContact and not joined:
        status_chat.deactivateChat(chat)
      else:
        result.add(chat)
    else:
      result.add(chat)

proc update*(self: ChatModel, chats: seq[Chat], messages: seq[Message], emojiReactions: seq[Reaction], communities: seq[Community], communityMembershipRequests: seq[CommunityMembershipRequest]) =
  var contacts = getAddedContacts()

  # Automatically decline chat group invitations if admin is not a contact
  var chatList = self.cleanSpamChatGroups(chats, contacts)

  for chat in chatList:
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
      
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chatList, contacts: @[], emojiReactions: emojiReactions, communities: communities, communityMembershipRequests: communityMembershipRequests))

proc hasChannel*(self: ChatModel, chatId: string): bool =
  self.channels.hasKey(chatId)

proc getActiveChannel*(self: ChatModel): string =
  if (self.channels.len == 0): "" else: toSeq(self.channels.values)[self.channels.len - 1].id

proc join*(self: ChatModel, chatId: string, chatType: ChatType, ensName: string = "", pubKey: string = "") =
  if self.hasChannel(chatId): return

  var chat = newChat(chatId, ChatType(chatType))
  self.channels[chat.id] = chat
  status_chat.saveChat(chatId, chatType, color=chat.color, ensName=ensName, profile=pubKey)
  if ensName != "":
    chat.name = ensName
    chat.ensName = ensName
    
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

proc requestMissingCommunityInfos*(self: ChatModel) =
  if (self.communitiesToFetch.len == 0):
    return
  for communityId in self.communitiesToFetch:
    status_chat.requestCommunityInfo(communityId)

proc init*(self: ChatModel, pubKey: string) =
  self.publicKey = pubKey

  var contacts = getAddedContacts()

  var chatList = self.cleanSpamChatGroups(status_chat.loadChats(), contacts)

  let profileUpdatesChatIds = chatList.filter(c => c.chatType == ChatType.Profile).map(c => c.id)

  if chatList.filter(c => c.chatType == ChatType.Timeline).len == 0:
    var timelineChannel = newChat(status_utils.getTimelineChatId(), ChatType.Timeline)
    self.join(timelineChannel.id, timelineChannel.chatType)
    chatList.add(timelineChannel)

  let timelineChatId = status_utils.getTimelineChatId(pubKey)

  if not profileUpdatesChatIds.contains(timelineChatId):
    var profileUpdateChannel = newChat(timelineChatId, ChatType.Profile)
    status_chat.saveChat(profileUpdateChannel.id, profileUpdateChannel.chatType, profile=pubKey)
    chatList.add(profileUpdateChannel)

  # For profile updates and timeline, we have to make sure that for
  # each added contact, a chat has been saved for the currently logged-in
  # user. Users that will use a version of Status with timeline support for the
  # first time, won't have any of those otherwise.
  if profileUpdatesChatIds.filter(id => id != timelineChatId).len != contacts.len:
    for contact in contacts:
      if not profileUpdatesChatIds.contains(status_utils.getTimelineChatId(contact.address)):
        let profileUpdatesChannel = newChat(status_utils.getTimelineChatId(contact.address), ChatType.Profile)
        status_chat.saveChat(profileUpdatesChannel.id, profileUpdatesChannel.chatType, ensName=contact.ensName, profile=contact.address)
        chatList.add(profileUpdatesChannel)

  var filters:seq[JsonNode] = @[]
  for chat in chatList:
    if self.hasChannel(chat.id):
      continue
    filters.add status_chat.buildFilter(chat)
    self.channels[chat.id] = chat
    self.events.emit("channelLoaded", ChannelArgs(chat: chat))

  if filters.len == 0: return

  let filterResult = status_chat.loadFilters(filters)

  self.events.emit("chatsLoaded", ChatArgs(chats: chatList))

  var topics:seq[MailserverTopic] = @[]
  let parsedResult = parseJson(filterResult)["result"]
  for filter in parsedResult:
    # Only add topics for chats the user has joined
    let topic_chat = filter["chatId"].getStr
    let identity = filter["identity"].getStr
    let chatId = if self.channels.hasKey(topic_chat): topic_chat else: "0x" & identity

    if self.channels.hasKey(chatId) and self.channels[chatId].isActive:
      topics.add(MailserverTopic(
        topic: $filter["topic"].getStr,
        discovery: filter["discovery"].getBool,
        negotiated: filter["negotiated"].getBool,
        chatIds: @[chatId],
        lastRequest: 1
      ))

  if (topics.len == 0): 
    warn "No topics found for chats. Cannot load past messages"
  else:
    self.events.once("mailserverAvailable") do(a: Args):
      self.mailserverReady = true
      self.requestMissingCommunityInfos()
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
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: backToFirstChat))

proc clearHistory*(self: ChatModel, chatId: string) =
  discard status_chat.clearChatHistory(chatId)
  let chat = self.channels[chatId]
  self.events.emit("chatHistoryCleared", ChannelArgs(chat: chat))

proc setActiveChannel*(self: ChatModel, chatId: string) =
  self.events.emit("activeChannelChanged", ChatIdArg(chatId: chatId))

proc processMessageUpdateAfterSend(self: ChatModel, response: string, forceActiveChat: bool = false): (seq[Chat], seq[Message])  =
  result = self.processChatUpdate(parseJson(response))
  var (chats, messages) = result
  if chats.len == 0 or messages.len == 0:
    self.events.emit("sendingMessageFailed", MessageArgs())
  else:
    if (forceActiveChat):
      chats[0].isActive = true
    self.events.emit("chatUpdate", ChatUpdateArgs(messages: messages, chats: chats, contacts: @[]))
    for msg in messages:
      self.events.emit("sendingMessage", MessageArgs(id: msg.id, channel: msg.chatId))

proc sendMessage*(self: ChatModel, chatId: string, msg: string, replyTo: string = "", contentType: int = ContentType.Message.int, communityId: string = "", forceActiveChat: bool = false) =
  var response = status_chat.sendChatMessage(chatId, msg, replyTo, contentType, communityId)
  discard self.processMessageUpdateAfterSend(response, forceActiveChat)

proc sendImage*(self: ChatModel, chatId: string, image: string) =
  var response = status_chat.sendImageMessage(chatId, image)
  discard self.processMessageUpdateAfterSend(response)

proc sendImages*(self: ChatModel, chatId: string, images: var seq[string]) =
  var response = status_chat.sendImageMessages(chatId, images)
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


proc chatMessages*(self: ChatModel, chatId: string, initialLoad:bool = true, cursor: string = "", messages: seq[Message]) =
  if not self.msgCursor.hasKey(chatId):
    self.msgCursor[chatId] = "";

  # Messages were already loaded, since cursor will 
  # be nil/empty if there are no more messages
  if(not initialLoad and self.msgCursor[chatId] == ""): return

  self.msgCursor[chatId] = cursor

  if messages.len > 0:
    let lastMsgIndex = messages.len - 1
    let ts = times.convert(Milliseconds, Seconds, messages[lastMsgIndex].whisperTimestamp.parseInt())
    self.lastMessageTimestamps[chatId] = ts

  self.events.emit("messagesLoaded", MsgsLoadedArgs(messages: messages))

proc chatReactions*(self: ChatModel, chatId: string, initialLoad:bool = true, cursor: string = "", reactions: seq[Reaction]) =
  try:
    if not self.emojiCursor.hasKey(chatId):
      self.emojiCursor[chatId] = "";

    # Messages were already loaded, since cursor will 
    # be nil/empty if there are no more messages
    if(not initialLoad and self.emojiCursor[chatId] == ""): return

    self.emojiCursor[chatId] = cursor;
    self.events.emit("reactionsLoaded", ReactionsLoadedArgs(reactions: reactions))
  except Exception as e:
    error "Error reactions", msg = e.msg

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

proc muteChat*(self: ChatModel, chat: Chat) =
  discard status_chat.muteChat(chat.id)
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: @[], chats: @[chat], contacts: @[]))

proc unmuteChat*(self: ChatModel, chat: Chat) =
  discard status_chat.unmuteChat(chat.id)
  self.events.emit("chatUpdate", ChatUpdateArgs(messages: @[], chats: @[chat], contacts: @[]))

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

proc getAllComunities*(self: ChatModel): seq[Community] =
  result = status_chat.getAllComunities()

proc getJoinedComunities*(self: ChatModel): seq[Community] =
  result = status_chat.getJoinedComunities()

proc createCommunity*(self: ChatModel, name: string, description: string, access: int, ensOnly: bool, color: string, imageUrl: string, aX: int, aY: int, bX: int, bY: int): Community =
  result = status_chat.createCommunity(name, description, access, ensOnly, color, imageUrl, aX, aY, bX, bY)

proc createCommunityChannel*(self: ChatModel, communityId: string, name: string, description: string): Chat =
  result = status_chat.createCommunityChannel(communityId, name, description)

proc joinCommunity*(self: ChatModel, communityId: string) =
  status_chat.joinCommunity(communityId)

proc requestCommunityInfo*(self: ChatModel, communityId: string) =
  if (not self.mailserverReady):
    self.communitiesToFetch.add(communityId)
    self.communitiesToFetch = self.communitiesToFetch.deduplicate()
    return
  status_chat.requestCommunityInfo(communityId)

proc leaveCommunity*(self: ChatModel, communityId: string) =
  status_chat.leaveCommunity(communityId)

proc inviteUserToCommunity*(self: ChatModel, communityId: string, pubKey: string) =
  status_chat.inviteUsersToCommunity(communityId, @[pubKey])

proc inviteUsersToCommunity*(self: ChatModel, communityId: string, pubKeys: seq[string]) =
  status_chat.inviteUsersToCommunity(communityId, pubKeys)

proc removeUserFromCommunity*(self: ChatModel, communityId: string, pubKey: string) =
  status_chat.removeUserFromCommunity(communityId, pubKey)

proc exportCommunity*(self: ChatModel, communityId: string): string =
  result = status_chat.exportCommunity(communityId)

proc importCommunity*(self: ChatModel, communityKey: string): string =
  result = status_chat.importCommunity(communityKey)

proc requestToJoinCommunity*(self: ChatModel, communityKey: string, ensName: string): seq[CommunityMembershipRequest] =
  status_chat.requestToJoinCommunity(communityKey, ensName)

proc acceptRequestToJoinCommunity*(self: ChatModel, requestId: string) =
  status_chat.acceptRequestToJoinCommunity(requestId)

proc declineRequestToJoinCommunity*(self: ChatModel, requestId: string) =
  status_chat.declineRequestToJoinCommunity(requestId)

proc pendingRequestsToJoinForCommunity*(self: ChatModel, communityKey: string): seq[CommunityMembershipRequest] =
  result = status_chat.pendingRequestsToJoinForCommunity(communityKey)

proc myPendingRequestsToJoin*(self: ChatModel): seq[CommunityMembershipRequest] =
  result = status_chat.myPendingRequestsToJoin()