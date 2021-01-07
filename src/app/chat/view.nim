import NimQml, Tables, json, sequtils, chronicles, times, re, sugar, strutils, os, strformat
import ../../status/status
import ../../status/mailservers
import ../../status/libstatus/accounts/constants
import ../../status/libstatus/mailservers as status_mailservers
import ../../status/libstatus/types
import ../../status/accounts as status_accounts
import ../../status/chat as status_chat
import ../../status/messages as status_messages
import ../../status/contacts as status_contacts
import ../../status/ens as status_ens
import ../../status/chat/[chat, message]
import ../../status/profile/profile
import web3/[conversions, ethtypes]
import ../../status/threads
import views/[channels_list, message_list, chat_item, suggestions_list, reactions, stickers, groups, transactions]
import json_serialization
import ../utils/image_utils

logScope:
  topics = "chats-view"

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      chats*: ChannelsList
      currentSuggestions*: SuggestionsList
      callResult: string
      messageList*: Table[string, ChatMessageList]
      reactions*: ReactionView
      stickers*: StickersView
      groups*: GroupsView
      transactions*: TransactionsView
      activeChannel*: ChatItemView
      replyTo: string
      channelOpenTime*: Table[string, int64]
      connected: bool
      unreadMessageCnt: int
      oldestMessageTimestamp: int64
      loadingMessages: bool
      pubKey*: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = 
    self.chats.delete
    self.activeChannel.delete
    self.currentSuggestions.delete
    for msg in self.messageList.values:
      msg.delete
    self.reactions.delete
    self.stickers.delete
    self.groups.delete
    self.transactions.delete
    self.messageList = initTable[string, ChatMessageList]()
    self.channelOpenTime = initTable[string, int64]()
    self.QAbstractListModel.delete

  proc newChatsView*(status: Status): ChatsView =
    new(result, delete)
    result.status = status
    result.connected = false
    result.chats = newChannelsList(status)
    result.activeChannel = newChatItemView(status)
    result.currentSuggestions = newSuggestionsList()
    result.messageList = initTable[string, ChatMessageList]()
    result.reactions = newReactionView(status, result.messageList.addr, result.activeChannel)
    result.stickers = newStickersView(status, result.activeChannel)
    result.groups = newGroupsView(status,result.activeChannel)
    result.transactions = newTransactionsView(status)
    result.unreadMessageCnt = 0
    result.loadingMessages = false
    result.setup()

  proc oldestMessageTimestampChanged*(self: ChatsView) {.signal.}

  proc getOldestMessageTimestamp*(self: ChatsView): QVariant {.slot.}  =
    newQVariant($self.oldestMessageTimestamp)

  QtProperty[QVariant] oldestMsgTimestamp:
    read = getOldestMessageTimestamp
    notify = oldestMessageTimestampChanged

  proc setLastMessageTimestamp(self: ChatsView, force = false) = 
    if self.status.chat.lastMessageTimestamps.hasKey(self.activeChannel.id):
      if force or self.status.chat.lastMessageTimestamps[self.activeChannel.id] <= self.oldestMessageTimestamp:
        self.oldestMessageTimestamp = self.status.chat.lastMessageTimestamps[self.activeChannel.id]
    else:
      let topics = self.status.mailservers.getMailserverTopicsByChatId(self.activeChannel.id)
      if topics.len > 0:
        self.oldestMessageTimestamp = topics[0].lastRequest
      else:
        self.oldestMessageTimestamp = times.toUnix(times.getTime())
    self.oldestMessageTimestampChanged()

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc replaceMentionsWithPubKeys(self: ChatsView, mentions: seq[string], contacts: seq[Profile], message: string, predicate: proc (contact: Profile): string): string =
    var updatedMessage = message
    for mention in mentions:
      let matches = contacts.filter(c => "@" & predicate(c).toLowerAscii == mention.toLowerAscii).map(c => c.address)
      if matches.len > 0:
        let pubKey = matches[0]
        var startIndex = 0
        var index = updatedMessage.find(mention)

        while index > -1:
          if index == 0 or updatedMessage[index-1] == ' ':
            updatedMessage = updatedMessage.replaceWord(mention, '@' & pubKey)
          startIndex = index + mention.len
          index = updatedMessage.find(mention, startIndex)

    result = updatedMessage

  proc plainText(self: ChatsView, input: string): string {.slot.} =
    result = plain_text(input)

  proc sendMessage*(self: ChatsView, message: string, replyTo: string, contentType: int = ContentType.Message.int, isStatusUpdate: bool = false) {.slot.} =
    let aliasPattern = re(r"(@[A-z][a-z]+ [A-z][a-z]* [A-z][a-z]*)", flags = {reStudy, reIgnoreCase})
    let ensPattern = re(r"(@\w+(?=(\.stateofus)?\.eth))", flags = {reStudy, reIgnoreCase})
    let namePattern = re(r"(@\w+)", flags = {reStudy, reIgnoreCase})

    let contacts = self.status.contacts.getContacts()

    let aliasMentions = findAll(message, aliasPattern)
    let ensMentions = findAll(message, ensPattern)
    let nameMentions = findAll(message, namePattern)

    var m = self.replaceMentionsWithPubKeys(aliasMentions, contacts, message, (c => c.alias))
    m = self.replaceMentionsWithPubKeys(ensMentions, contacts, m, (c => c.ensName))
    m = self.replaceMentionsWithPubKeys(nameMentions, contacts, m, (c => c.ensName.split(".")[0]))

    var channelId = self.activeChannel.id

    if isStatusUpdate:
      channelId = "@" & self.pubKey

    self.status.chat.sendMessage(channelId, m, replyTo, contentType)

  proc sendPluginMessage*(self: ChatsView, message: string) {.slot.} =
    var channelId = self.activeChannel.id
    self.status.chat.sendPluginMessage(channelId, message, "")

  proc verifyMessageSent*(self: ChatsView, data: string) {.slot.} =
    let messageData = data.parseJson
    self.messageList[messageData["chatId"].getStr].checkTimeout(messageData["id"].getStr)

  proc resendMessage*(self: ChatsView, chatId: string, messageId: string) {.slot.} =
    self.status.messages.trackMessage(messageId, chatId)
    self.status.chat.resendMessage(messageId)
    self.messageList[chatId].resetTimeOut(messageId)

  proc sendImage*(self: ChatsView, imagePath: string, isStatusUpdate: bool = false): string {.slot.} =
    result = ""
    try:
      var image = image_utils.formatImagePath(imagePath)
      let tmpImagePath = image_resizer(image, 2000, TMPDIR)

      var channelId = self.activeChannel.id
      
      if isStatusUpdate:
        channelId = "@" & self.pubKey

      self.status.chat.sendImage(channelId, tmpImagePath)
      removeFile(tmpImagePath)
    except Exception as e:
      error "Error sending the image", msg = e.msg
      result = fmt"Error sending the image: {e.msg}"

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc sendingMessage*(self: ChatsView) {.signal.}

  proc appReady*(self: ChatsView) {.signal.}

  proc sendingMessageFailed*(self: ChatsView) {.signal.}

  proc alias*(self: ChatsView, pubKey: string): string {.slot.} =
    generateAlias(pubKey)

  proc userNameOrAlias*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.contacts.hasKey(pubKey):
      return status_ens.userNameOrAlias(self.status.chat.contacts[pubKey])
    generateAlias(pubKey)

  proc markAllChannelMessagesReadByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    discard self.status.chat.markAllChannelMessagesRead(selectedChannel.id)

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return
    if(not self.activeChannel.chatItem.isNil and self.activeChannel.chatItem.unviewedMessagesCount > 0):
      var response = self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
      if not response.hasKey("error"):
        self.chats.clearUnreadMessagesCount(self.activeChannel.chatItem)
    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel.id == selectedChannel.id: return

    if selectedChannel.chatType.isOneToOne and selectedChannel.id == selectedChannel.name:
        selectedChannel.name = self.userNameOrAlias(selectedChannel.id)

    self.activeChannel.setChatItem(selectedChannel)
    self.status.chat.setActiveChannel(selectedChannel.id)

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats.chats.findIndexById(self.activeChannel.id))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged

  proc setActiveChannel*(self: ChatsView, channel: string) {.slot.} =
    if(channel == ""): return
    self.activeChannel.setChatItem(self.chats.getChannel(self.chats.chats.findIndexById(channel)))
    discard self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
    self.setLastMessageTimestamp(true)
    self.activeChannelChanged()

  proc getActiveChannel*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeChannel)

  QtProperty[QVariant] activeChannel:
    read = getActiveChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc getCurrentSuggestions(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.currentSuggestions)

  QtProperty[QVariant] suggestionList:
    read = getCurrentSuggestions

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList(channel, self.status)
      self.channelOpenTime[channel] = now().toTime.toUnix * 1000

  proc fullMessagePushed*(self: ChatsView, chatId: string, text: string) {.signal.}
  proc messagePushed*(self: ChatsView) {.signal.}
  proc newMessagePushed*(self: ChatsView) {.signal.}

  proc pluginMessagePushed*(self: ChatsView, chatId: string, text: string, messageType: string, chatType: int, timestamp: string, identicon: string, username: string, hasMention: bool, isAddedContact: bool, channelName: string) {.signal.}

  proc messageNotificationPushed*(self: ChatsView, chatId: string, text: string, messageType: string, chatType: int, timestamp: string, identicon: string, username: string, hasMention: bool, isAddedContact: bool, channelName: string) {.signal.}

  proc messagesCleared*(self: ChatsView) {.signal.}

  proc clearMessages*(self: ChatsView, id: string) =
    self.messageList[id].clear()
    self.messagesCleared()

  proc pushMessages*(self:ChatsView, messages: var seq[Message]) =
    for msg in messages.mitems:
      echo $msg.contentType
      # if $msg.contentType == "Unknown":
      # if 1 == 2:
      if msg.text.startsWith("pluginMsg|"):
        echo "plugin message received"
        let channel = self.chats.getChannelById(msg.chatId)
        let isAddedContact = channel.chatType.isOneToOne and self.status.contacts.isAdded(channel.id)
        self.pluginMessagePushed(
          msg.chatId,
          # escape_html(msg.text),
          msg.text,
          msg.messageType,
          channel.chatType.int,
          msg.timestamp,
          msg.identicon,
          msg.alias,
          msg.hasMention,
          isAddedContact,
          channel.name)
      else:
        self.upsertChannel(msg.chatId)
        msg.userName = self.status.chat.getUserName(msg.fromAuthor, msg.alias)
        self.messageList[msg.chatId].add(msg)
        self.messagePushed()
        self.fullMessagePushed(msg.chatId, msg.text)
        if self.channelOpenTime.getOrDefault(msg.chatId, high(int64)) < msg.timestamp.parseFloat.fromUnixFloat.toUnix:
          let channel = self.chats.getChannelById(msg.chatId)
          let isAddedContact = channel.chatType.isOneToOne and self.status.contacts.isAdded(channel.id)
          if not channel.muted:
            self.messageNotificationPushed(
              msg.chatId,
              escape_html(msg.text),
              msg.messageType,
              channel.chatType.int,
              msg.timestamp,
              msg.identicon,
              msg.alias,
              msg.hasMention,
              isAddedContact,
              channel.name)

          else:
            discard self.status.chat.markMessagesSeen(msg.chatId, @[msg.id])
            self.newMessagePushed()

  proc updateUsernames*(self:ChatsView, contacts: seq[Profile]) =
    if contacts.len > 0:
      # Updating usernames for all the messages list
      for k in self.messageList.keys:
        self.messageList[k].updateUsernames(contacts)
      self.activeChannel.contactsUpdated()

  proc updateChannelForContacts*(self: ChatsView, contacts: seq[Profile]) =
    for contact in contacts:
      let channel = self.chats.getChannelById(contact.id)
      if not channel.isNil:
        if contact.localNickname == "":
          if channel.name == "" or channel.name == channel.id:
            if channel.ensName != "":
              channel.name = channel.ensName
            else: 
              channel.name = contact.username
        else:
          channel.name = contact.localNickname
        self.chats.updateChat(channel, false)
        if (self.activeChannel.id == channel.id):
          self.activeChannel.setChatItem(channel)
          self.activeChannelChanged()


  proc markMessageAsSent*(self:ChatsView, chat: string, messageId: string) =
    self.messageList[chat].markMessageAsSent(messageId)

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel.id)
    return newQVariant(self.messageList[self.activeChannel.id])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.chats.addChatItemToList(chatItem)
    self.messagePushed()
  
  proc copyToClipboard*(self: ChatsView, content: string) {.slot.} =
    setClipBoardText(content)

  proc getLinkPreviewData*(self: ChatsView, link: string): string {.slot.} =
    try:
      $self.status.chat.getLinkPreviewData(link)
    except RpcException as e:
      $ %* { "error": e.msg }

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.status.chat.join(channel, ChatType(chatTypeInt))
    self.setActiveChannel(channel)

  proc joinChatWithENS*(self: ChatsView, channel: string, ensName: string): int {.slot.} =
    self.status.chat.join(channel, ChatType.OneToOne, ensName=status_ens.addDomain(ensName))
    self.setActiveChannel(channel)

  proc messagesLoaded*(self: ChatsView) {.signal.}

  proc loadMoreMessages*(self: ChatsView) {.slot.} =
    trace "Loading more messages", chaId = self.activeChannel.id
    self.status.chat.chatMessages(self.activeChannel.id, false)
    self.status.chat.chatReactions(self.activeChannel.id, false)
    if self.status.chat.msgCursor[self.activeChannel.id] == "":
      self.setLastMessageTimestamp()
    self.messagesLoaded();

  proc loadMoreMessagesWithIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    trace "Loading more messages", chaId = selectedChannel.id
    self.status.chat.chatMessages(selectedChannel.id, false)
    self.status.chat.chatReactions(selectedChannel.id, false)
    self.setLastMessageTimestamp()
    self.messagesLoaded();

  proc loadingMessagesChanged*(self: ChatsView, value: bool) {.signal.}

  proc hideLoadingIndicator*(self: ChatsView) {.slot.} =
    self.loadingMessages = false
    self.loadingMessagesChanged(false)

  proc setLoadingMessages*(self: ChatsView, value: bool) {.slot.} =
    self.loadingMessages = value
    self.loadingMessagesChanged(value)

  proc isLoadingMessages(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.loadingMessages)

  QtProperty[QVariant] loadingMessages:
    read = isLoadingMessages
    write = setLoadingMessages
    notify = loadingMessagesChanged

  proc requestMoreMessages*(self: ChatsView, fetchRange: int) {.slot.} =
    self.loadingMessages = true
    self.loadingMessagesChanged(true)
    let topics = self.status.mailservers.getMailserverTopicsByChatId(self.activeChannel.id).map(topic => topic.topic)
    let currentOldestMessageTimestamp = self.oldestMessageTimestamp
    self.oldestMessageTimestamp = self.oldestMessageTimestamp - fetchRange

    self.status.mailservers.requestMessages(topics, self.oldestMessageTimestamp, currentOldestMessageTimestamp, true)
    self.oldestMessageTimestampChanged()
    self.messagesLoaded();

  proc leaveChatByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.leave(selectedChannel.id)

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.status.chat.leave(self.activeChannel.id)

  proc removeChat*(self: ChatsView, chatId: string) =
    discard self.chats.removeChatItemFromList(chatId)
    self.messageList[chatId].delete
    self.messageList.del(chatId)

  proc clearChatHistory*(self: ChatsView, id: string) {.slot.} =
    self.status.chat.clearHistory(id)

  proc clearChatHistoryByIndex*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    self.status.chat.clearHistory(selectedChannel.id)

  proc unreadMessages*(self: ChatsView): int {.slot.} =
    result = self.unreadMessageCnt

  proc unreadMessagesCntChanged*(self: ChatsView) {.signal.}

  QtProperty[int] unreadMessagesCount:
    read = unreadMessages
    notify = unreadMessagesCntChanged

  proc calculateUnreadMessages*(self: ChatsView) =
    var unreadTotal = 0
    for chatItem in self.chats.chats:
      unreadTotal = unreadTotal + chatItem.unviewedMessagesCount
    if unreadTotal != self.unreadMessageCnt:
      self.unreadMessageCnt = unreadTotal
      self.unreadMessagesCntChanged()

  proc updateChats*(self: ChatsView, chats: seq[Chat], triggerChange:bool = true) =
    for chat in chats:
      self.upsertChannel(chat.id)
      self.chats.updateChat(chat, triggerChange)
      if(self.activeChannel.id == chat.id):
        self.activeChannel.setChatItem(chat)
        self.currentSuggestions.setNewData(self.status.contacts.getContacts())
    self.calculateUnreadMessages()

  proc deleteMessage*(self: ChatsView, channelId: string, messageId: string) =
    self.messageList[channelId].deleteMessage(messageId)

  proc isEnsVerified*(self: ChatsView, id: string): bool {.slot.} =
    if id == "": return false
    let contact = self.status.contacts.getContactByID(id)
    if contact == nil:
      return false
    result = contact.ensVerified

  proc formatENSUsername*(self: ChatsView, username: string): string {.slot.} =
    result = status_ens.addDomain(username)

  # Resolving a ENS name
  proc resolveENS*(self: ChatsView, ens: string) {.slot.} =
    spawnAndSend(self, "ensResolved") do: # Call self.ensResolved(string) when ens is resolved
      status_ens.pubkey(ens)

  proc ensWasResolved*(self: ChatsView, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: ChatsView, pubKey: string) {.slot.} =
    self.ensWasResolved(pubKey)

  proc isConnected*(self: ChatsView): bool {.slot.} =
    result = self.status.network.isConnected

  proc onlineStatusChanged(self: ChatsView, connected: bool) {.signal.}

  proc setConnected*(self: ChatsView, connected: bool) =
    self.connected = connected
    self.onlineStatusChanged(connected)

  QtProperty[bool] isOnline:
    read = isConnected
    notify = onlineStatusChanged

  proc muteChannel*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    selectedChannel.muted = true
    self.status.chat.muteChat(selectedChannel)
    self.chats.updateChat(selectedChannel, false)

  proc unmuteChannel*(self: ChatsView, channelIndex: int) {.slot.} =
    if (self.chats.chats.len == 0): return
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return
    selectedChannel.muted = false
    self.status.chat.unmuteChat(selectedChannel)
    self.chats.updateChat(selectedChannel, false)

  proc channelIsMuted*(self: ChatsView, channelIndex: int): bool {.slot.} =
    if (self.chats.chats.len == 0): return false
    let selectedChannel = self.chats.getChannel(channelIndex)
    if (selectedChannel == nil): return false
    result = selectedChannel.muted  

  proc getReactions*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.reactions)

  QtProperty[QVariant] reactions:
    read = getReactions

  proc getStickers*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.stickers)

  QtProperty[QVariant] stickers:
    read = getStickers

  proc getGroups*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.groups)

  QtProperty[QVariant] groups:
    read = getGroups

  proc getTransactions*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.transactions)

  QtProperty[QVariant] transactions:
    read = getTransactions
