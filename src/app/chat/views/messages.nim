import NimQml, Tables, json, sequtils, chronicles, times, re, strutils, sugar

import status/[status, contacts]
import status/messages as status_messages
import status/utils as status_utils
import status/chat/[chat]
import status/types/[message, profile]

import ../../../app_service/[main]
import ../../../app_service/tasks/[qt, threadpool]
import ../../../app_service/tasks/marathon/mailserver/worker

import communities, chat_item, channels_list, communities, user_list, community_members_list, message_list, channel, message_item, message_format

logScope:
  topics = "messages-view"

type
  ChatViewRoles {.pure.} = enum
    MessageList = UserRole + 1
    ChatId

QtObject:
  type MessageView* = ref object of QAbstractListModel
    status: Status
    appService: AppService
    messageList*: OrderedTable[string, ChatMessageList]
    pinnedMessagesList*: OrderedTable[string, ChatMessageList]
    channelView*: ChannelView
    communities*: CommunitiesView
    pubKey*: string
    loadingMessages*: bool
    unreadMessageCnt: int
    unreadDirectMessagesAndMentionsCount: int
    channelOpenTime*: Table[string, int64]
    searchedMessageId: string

  proc setup(self: MessageView) = self.QAbstractListModel.setup
  proc delete*(self: MessageView) =
    for msg in self.messageList.values:
      msg.delete
    for msg in self.pinnedMessagesList.values:
      msg.delete
    self.messageList = initOrderedTable[string, ChatMessageList]()
    self.pinnedMessagesList = initOrderedTable[string, ChatMessageList]()
    self.channelOpenTime = initTable[string, int64]()
    self.QAbstractListModel.delete

  proc newMessageView*(status: Status, appService: AppService, channelView: ChannelView, communitiesView: CommunitiesView): MessageView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.channelView = channelView
    result.communities = communitiesView
    result.messageList = initOrderedTable[string, ChatMessageList]()
    result.pinnedMessagesList = initOrderedTable[string, ChatMessageList]()
    result.messageList[status_utils.getTimelineChatId()] = newChatMessageList(status_utils.getTimelineChatId(), result.status, false)
    result.loadingMessages = false
    result.unreadMessageCnt = 0
    result.unreadDirectMessagesAndMentionsCount = 0
    result.setup

  #################################################
  # Forward declaration section
  #################################################
  proc checkIfSearchedMessageIsLoaded(self: MessageView, chatId: string)
  proc setLoadingHistoryMessages*(self: MessageView, chatId: string, value: bool)
  proc setInitialMessagesLoaded*(self: MessageView, chatId: string, value: bool)

  proc replaceMentionsWithPubKeys(self: MessageView, message: string): string =
    let aliasPattern = re(r"(@[A-z][a-z]+ [A-z][a-z]* [A-z][a-z]*)", flags = {reStudy, reIgnoreCase})
    let ensPattern = re(r"(@\w+(?=(\.stateofus)?\.eth))", flags = {reStudy, reIgnoreCase})
    let namePattern = re(r"(@\w+)", flags = {reStudy, reIgnoreCase})

    let aliasMentions = findAll(message, aliasPattern)
    let ensMentions = findAll(message, ensPattern)
    let nameMentions = findAll(message, namePattern)
    var updatedMessage = message

    var userList = self.messageList[self.channelView.activeChannel.id].userList.users

    if self.communities.activeCommunity.active:
      userList = self.communities.activeCommunity.members.community.members

    for publicKey in userList:
      
      var user = if self.communities.activeCommunity.active:
        self.communities.activeCommunity.members.getUserFromPubKey(publicKey)
      else:
        self.messageList[self.channelView.activeChannel.id].userList.userDetails[publicKey]

      let userName = if user.userName.startsWith('@'):
        user.userName
      else:
        "@" & user.userName

      for mention in aliasMentions:
        if "@" & user.alias.toLowerAscii != mention.toLowerAscii:
          continue

        updatedMessage = updatedMessage.replaceWord(mention, '@' & publicKey)

      for mention in ensMentions:
        if userName.toLowerAscii != mention.toLowerAscii:
          continue

        updatedMessage = updatedMessage.replaceWord(mention, '@' & publicKey)

      for mention in nameMentions:
        if userName.split(".")[0].toLowerAscii != mention.toLowerAscii:
          continue

        updatedMessage = updatedMessage.replaceWord(mention, '@' & publicKey)

    return updatedMessage

  proc replacePubKeysWithMentions(self: MessageView, message: string): string =
    let pubKeyPattern = re(r"(@0[xX][0-9a-fA-F]+)", flags = {reStudy, reIgnoreCase})
    let pubKeyMentions = findAll(message, pubKeyPattern)
    var updatedMessage = message

    for mention in pubKeyMentions:
      let pubKey = mention.replace("@","")
      let userNameAlias = mention(pubKey, self.status.chat.getContacts())
      if userNameAlias != "":
        updatedMessage = updatedMessage.replace(mention, '@' & userNameAlias)

    return updatedMessage

  proc hideMessage(self: MessageView, mId: string) {.signal.}

  proc sendOrEditMessage*(self: MessageView, message: string, replyTo: string, contentType: int = ContentType.Message.int, isStatusUpdate: bool = false, isEdit: bool = false, messageId: string = "") {.slot.} =
    let updatedMessage = self.replaceMentionsWithPubKeys(message)
    var channelId = self.channelView.activeChannel.id

    if isStatusUpdate:
      channelId = "@" & self.pubKey

    if not isEdit:
      self.status.chat.sendMessage(channelId, updatedMessage, replyTo, contentType)
    else:
      self.status.chat.editMessage(messageId, updatedMessage)

  proc sendMessage*(self: MessageView, message: string, replyTo: string, contentType: int = ContentType.Message.int, isStatusUpdate: bool = false) {.slot.} =
    self.sendOrEditMessage(message, replyTo, contentType, isStatusUpdate, false, "")

  proc resendMessage*(self: MessageView, chatId: string, messageId: string) {.slot.} =
    self.status.messages.trackMessage(messageId, chatId)
    self.status.chat.resendMessage(messageId)
    self.messageList[chatId].resetTimeOut(messageId)

  proc sendingMessageSuccess*(self: MessageView) {.signal.}

  proc sendingMessageFailed*(self: MessageView) {.signal.}

  proc messageEdited(self: MessageView, editedMessageId: string, editedMessageContent: string) {.signal.}

  proc editMessage*(self: MessageView, messageId: string, originalMessageId: string, message: string) {.slot.} =
    self.sendOrEditMessage(message, "", ContentType.Message.int, false, true, originalMessageId)
    self.messageEdited(originalMessageId, message)

  proc messagePushed*(self: MessageView, messageIndex: int) {.signal.}
  proc newMessagePushed*(self: MessageView) {.signal.}

  proc messagesCleared*(self: MessageView) {.signal.}

  proc clearMessages*(self: MessageView, id: string) =
    let channel = self.channelView.getChannelById(id)
    if (channel == nil):
      return
    self.messageList[id].clear(not channel.isNil and channel.chatType != ChatType.Profile)
    self.messagesCleared()

  proc getBlockedContacts*(self: MessageView): seq[string] =
    return self.status.contacts.getContacts()
      .filter(c => c.isBlocked)
      .map(c => c.id)

  proc upsertChannel*(self: MessageView, channel: string) =
    var chat: Chat = nil
    if self.status.chat.channels.hasKey(channel):
      chat = self.status.chat.channels[channel]
    else:
      chat = self.communities.getChannel(channel)

    var blockedContacts: seq[string] = @[]
    if not self.messageList.hasKey(channel) or not self.pinnedMessagesList.hasKey(channel):
      blockedContacts = self.getBlockedContacts

    if not self.messageList.hasKey(channel):
      self.beginInsertRows(newQModelIndex(), self.messageList.len, self.messageList.len)
      self.messageList[channel] = newChatMessageList(channel, self.status, not chat.isNil and chat.chatType != ChatType.Profile, blockedContacts)
      self.channelOpenTime[channel] = now().toTime.toUnix * 1000
      self.endInsertRows();
    if not self.pinnedMessagesList.hasKey(channel):
      self.pinnedMessagesList[channel] = newChatMessageList(channel, self.status, false, blockedContacts)

  proc pushPinnedMessages*(self:MessageView, pinnedMessages: var seq[Message]) =
    for msg in pinnedMessages.mitems:
      self.upsertChannel(msg.chatId)

      var message = self.messageList[msg.chatId].getMessageById(msg.id)
      message.pinnedBy = msg.pinnedBy
      message.isPinned = true

      self.pinnedMessagesList[msg.chatId].add(message)
      # put the message as pinned in the message list
      self.messageList[msg.chatId].changeMessagePinned(msg.id, true, msg.pinnedBy)

  proc isAddedContact*(self: MessageView, id: string): bool {.slot.} =
    result = self.status.contacts.isAdded(id)

  proc messageNotificationPushed*(self: MessageView, messageId: string,
    communityId: string, chatId: string, text: string, contentType: int,
    chatType: int, timestamp: string, identicon: string, username: string,
    hasMention: bool, isAddedContact: bool, channelName: string) {.signal.}

  proc pushMembers*(self:MessageView, chats: seq[Chat]) =
    for chat in chats:
      if chat.chatType == ChatType.PrivateGroupChat and self.messageList.hasKey(chat.id):
        self.messageList[chat.id].addChatMembers(chat.members)

  proc pushMessages*(self:MessageView, messages: var seq[Message]) =
    for msg in messages.mitems:
      self.upsertChannel(msg.chatId)
      msg.userName = self.status.chat.getUserName(msg.fromAuthor, msg.alias)
      var msgIndex:int;
      if self.status.chat.channels.hasKey(msg.chatId):
        let chat = self.status.chat.channels[msg.chatId]
        if (chat.chatType == ChatType.Profile):
          let timelineChatId = status_utils.getTimelineChatId()
          self.messageList[timelineChatId].add(msg)

          if self.channelView.activeChannel.id == timelineChatId: self.channelView.activeChannelChanged()
          msgIndex = self.messageList[timelineChatId].count - 1
        else:
          self.messageList[msg.chatId].add(msg)
          if self.pinnedMessagesList[msg.chatId].contains(msg):
            self.pinnedMessagesList[msg.chatId].add(msg)

          msgIndex = self.messageList[msg.chatId].count - 1

      self.messagePushed(msgIndex)
      if self.channelOpenTime.getOrDefault(msg.chatId, high(int64)) < msg.timestamp.parseFloat.fromUnixFloat.toUnix:
        var channel = self.channelView.chats.getChannelById(msg.chatId)
        if (channel == nil):
          channel = self.communities.getChannel(msg.chatId)
          if (channel == nil):
            continue

        if msg.chatId == self.channelView.activeChannel.id:
          discard self.status.chat.markMessagesSeen(msg.chatId, @[msg.id])
          self.newMessagePushed()

        let isGroupSelf = msg.fromAuthor == self.pubKey and msg.contentType == ContentType.Group
        let isMyInvite = msg.fromAuthor == self.pubKey and msg.contentType == ContentType.Community
        let isEdit = msg.editedAt != "0" or msg.contentType == ContentType.Edit
        if not channel.muted and not isEdit and not isGroupSelf and not isMyInvite:
          let isAddedContact = channel.chatType.isOneToOne and self.isAddedContact(channel.id)
          self.messageNotificationPushed(msg.id, channel.communityId, msg.chatId, self.replacePubKeysWithMentions(msg.text), msg.contentType.int, channel.chatType.int, msg.timestamp, msg.identicon, msg.userName, msg.hasMention, isAddedContact, channel.name)

        self.channelOpenTime[msg.chatId] = now().toTime.toUnix * 1000

  proc markMessageAsSent*(self:MessageView, chat: string, messageId: string) =
    if self.messageList.contains(chat):
      self.messageList[chat].markMessageAsSent(messageId)
    else:
      error "Message could not be marked as sent", chat, messageId

  proc getMessageIndex(self: MessageView, chatId: string, messageId: string): int {.slot.} =
    if (not self.messageList.hasKey(chatId)):
      return -1
    result = self.messageList[chatId].getMessageIndex(messageId)

  proc getMessageData(self: MessageView, chatId: string,  index: int, data: string): string {.slot.} =
    if (not self.messageList.hasKey(chatId)):
      return

    return self.messageList[chatId].getMessageData(index, data)

  proc getMessageList(self: MessageView): QVariant {.slot.} =
    self.upsertChannel(self.channelView.activeChannel.id)
    return newQVariant(self.messageList[self.channelView.activeChannel.id])

  proc activeChannelChanged*(self: MessageView) {.signal.}

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc getPinnedMessagesList(self: MessageView): QVariant {.slot.} =
    self.upsertChannel(self.channelView.activeChannel.id)
    return newQVariant(self.pinnedMessagesList[self.channelView.activeChannel.id])

  QtProperty[QVariant] pinnedMessagesList:
    read = getPinnedMessagesList
    notify = activeChannelChanged

  proc messagesLoaded*(self: MessageView) {.signal.}

  proc loadMoreMessages*(self: MessageView, channelId: string) {.slot.} =
    discard
    # Not refactored yet, will be once we have corresponding qml part done.
    # self.setLoadingHistoryMessages(channelId, true)
    # self.appService.chatService.loadMoreMessagesForChannel(channelId)

  proc onMessagesLoaded*(self: MessageView, chatId: string, messages: var seq[Message]) =
    self.pushMessages(messages)
    self.messagesLoaded()

    self.setInitialMessagesLoaded(chatId, true)
    self.setLoadingHistoryMessages(chatId, false)
    self.checkIfSearchedMessageIsLoaded(chatId)

  proc loadingMessagesChanged*(self: MessageView, value: bool) {.signal.}

  proc hideLoadingIndicator*(self: MessageView) {.slot.} =
    self.loadingMessages = false
    self.loadingMessagesChanged(false)

  proc setLoadingMessages*(self: MessageView, value: bool) {.slot.} =
    self.loadingMessages = value
    self.loadingMessagesChanged(value)

  proc isLoadingMessages(self: MessageView): QVariant {.slot.} =
    return newQVariant(self.loadingMessages)

  QtProperty[QVariant] loadingMessages:
    read = isLoadingMessages
    write = setLoadingMessages
    notify = loadingMessagesChanged

  proc fillGaps*(self: MessageView, messageId: string) {.slot.} =
    self.setLoadingMessages(true)
    let mailserverWorker = self.appService.marathon[MailserverWorker().name]
    let task = FillGapsTaskArg( `method`: "fillGaps", chatId: self.channelView.activeChannel.id, messageIds: @[messageId])
    mailserverWorker.start(task)

  proc unreadMessages*(self: MessageView): int {.slot.} =
    result = self.unreadMessageCnt

  proc unreadMessagesCntChanged*(self: MessageView) {.signal.}

  QtProperty[int] unreadMessagesCount:
    read = unreadMessages
    notify = unreadMessagesCntChanged

  proc getUnreadDirectMessagesAndMentionsCount*(self: MessageView): int {.slot.} =
    result = self.unreadDirectMessagesAndMentionsCount

  proc unreadDirectMessagesAndMentionsCountChanged*(self: MessageView) {.signal.}

  QtProperty[int] unreadDirectMessagesAndMentionsCount:
    read = getUnreadDirectMessagesAndMentionsCount
    notify = unreadDirectMessagesAndMentionsCountChanged

  proc calculateUnreadMessages*(self: MessageView) =
    var unreadTotal = 0
    var currentUnreadDirectMessagesAndMentionsCount = 0
    for chatItem in self.channelView.chats.chats:
      if not chatItem.muted:
        unreadTotal = unreadTotal + chatItem.unviewedMessagesCount
        currentUnreadDirectMessagesAndMentionsCount = currentUnreadDirectMessagesAndMentionsCount + chatItem.mentionsCount
        if chatItem.chatType == ChatType.OneToOne:
          currentUnreadDirectMessagesAndMentionsCount = currentUnreadDirectMessagesAndMentionsCount + chatItem.unviewedMessagesCount
    if unreadTotal != self.unreadMessageCnt:
      self.unreadMessageCnt = unreadTotal
      self.unreadMessagesCntChanged()
    if self.unreadDirectMessagesAndMentionsCount != currentUnreadDirectMessagesAndMentionsCount:
      self.unreadDirectMessagesAndMentionsCount = currentUnreadDirectMessagesAndMentionsCount
      self.unreadDirectMessagesAndMentionsCountChanged()

  proc deleteMessage*(self: MessageView, channelId: string, messageId: string): bool =
    result = self.messageList[channelId].deleteMessage(messageId)
    if (result):
      discard self.pinnedMessagesList[channelId].deleteMessage(messageId)
      self.hideMessage(messageId)

  proc deleteMessageWhichReplacedMessageWithId*(self: MessageView, channelId: string, replacedMessageId: string): bool =
    ## Deletes a message which replaced a message with id "replacedMessageId" from
    ## a channel with id "channelId" and returns true if such message is successfully
    ## deleted, otherwise returns false.

    let msgIdToBeDeleted = self.messageList[channelId].getMessageIdWhichReplacedMessageWithId(replacedMessageId)
    if (msgIdToBeDeleted.len == 0):
      return false

    result = self.messageList[channelId].deleteMessage(msgIdToBeDeleted)
    if (result):
      self.hideMessage(msgIdToBeDeleted)

  proc blockContact*(self: MessageView, contactId: string) =
    for k in self.messageList.keys:
      self.messageList[k].blockContact(contactId)

  proc unblockContact*(self: MessageView, contactId: string) =
    for k in self.messageList.keys:
      self.messageList[k].unblockContact(contactId)

  proc getMessageListIndex(self: MessageView): int {.slot.} =
    var idx = -1
    for msg in toSeq(self.messageList.values):
      idx = idx + 1
      if(self.channelView.activeChannel.id == msg.id): return idx
    return idx

  proc getMessageListIndexById*(self: MessageView, id: string): int {.slot.} =
    var idx = -1
    for msg in toSeq(self.messageList.values):
      idx = idx + 1
      if(id == msg.id): return idx
    return idx

  proc addPinMessage*(self: MessageView, messageId: string, chatId: string, pinnedBy: string) =
    self.upsertChannel(chatId)
    if self.messageList[chatId].changeMessagePinned(messageId, true, pinnedBy):
      var message = self.messageList[chatId].getMessageById(messageId)
      message.pinnedBy = pinnedBy
      self.pinnedMessagesList[chatId].add(message)

  proc removePinMessage*(self: MessageView, messageId: string, chatId: string) =
    self.upsertChannel(chatId)
    if self.messageList[chatId].changeMessagePinned(messageId, false, ""):
      try:
        discard self.pinnedMessagesList[chatId].deleteMessage(messageId)
      except Exception as e:
        error "Error removing ", msg = e.msg

  proc pinMessage*(self: MessageView, messageId: string, chatId: string) {.slot.} =
    self.status.chat.setPinMessage(messageId, chatId, true)
    self.addPinMessage(messageId, chatId, self.pubKey)

  proc unPinMessage*(self: MessageView, messageId: string, chatId: string) {.slot.} =
    self.status.chat.setPinMessage(messageId, chatId, false)
    self.removePinMessage(messageId, chatId)

  proc refreshPinnedMessages*(self: MessageView, pinnedMessages: seq[Message]) =
    for pinnedMessage in pinnedMessages:
      if (pinnedMessage.isPinned):
        self.addPinMessage(pinnedMessage.id, pinnedMessage.localChatId, pinnedMessage.pinnedBy)
      else:
        self.removePinMessage(pinnedMessage.id, pinnedMessage.localChatId)

  method rowCount*(self: MessageView, index: QModelIndex = nil): int =
    result = self.messageList.len

  method data(self: MessageView, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.messageList.len:
      return

    let chatViewRole = role.ChatViewRoles
    case chatViewRole:
      of ChatViewRoles.ChatId: result = newQVariant(toSeq(self.messageList.keys)[index.row])
      of ChatViewRoles.MessageList: result = newQVariant(toSeq(self.messageList.values)[index.row])

  method roleNames(self: MessageView): Table[int, string] =
    {
      ChatViewRoles.ChatId.int:"chatId",
      ChatViewRoles.MessageList.int:"messages"
    }.toTable

  proc getChatIdForMessage*(self: MessageView, messageId: string): string =
    for chatId, messageList in self.messageList:
      for message in messageList.messages:
        if (message.id == messageId):
          return chatId

  proc deleteMessage*(self: MessageView, messageId: string) {.slot.} =
    self.status.chat.deleteMessageAndSend(messageId)
    let chatId = self.getChatIdForMessage(messageId)
    discard self.deleteMessage(chatId, messageId)

  proc removeChat*(self: MessageView, chatId: string) =
    if (not self.messageList.hasKey(chatId)):
      return

    let index = self.getMessageListIndexById(chatId)
    if (index < 0 or index >= self.messageList.len):
      return

    self.beginRemoveRows(newQModelIndex(), index, index)
    self.messageList[chatId].delete
    self.messageList.del(chatId)
    self.endRemoveRows()

  proc isMessageDisplayed(self: MessageView, messageId: string): bool =
    let chatId = self.channelView.activeChannel.id
    var message = self.messageList[chatId].getMessageById(messageId)

    return message.id != ""

  proc loadMessagesUntillMessageWithIdIsLoaded*(self: MessageView, messageId: string) =
    self.searchedMessageId = messageId
    let chatId = self.channelView.activeChannel.id

    self.loadMoreMessages(chatId)

  proc searchedMessageLoaded*(self: MessageView, messageId: string) {.signal.}

  proc checkIfSearchedMessageIsLoaded(self: MessageView, chatId: string) =
    if (self.searchedMessageId.len == 0):
      return

    if (self.isMessageDisplayed(self.searchedMessageId)):
      self.searchedMessageLoaded(self.searchedMessageId)
      self.searchedMessageId = ""
    else:
      self.loadMoreMessages(chatId)

  proc setLoadingHistoryMessages*(self: MessageView, chatId: string, value: bool) =
    if self.messageList.hasKey(chatId):
      self.messageList[chatId].setLoadingHistoryMessages(value)

  proc setInitialMessagesLoaded*(self: MessageView, chatId: string, value: bool) =
    if self.messageList.hasKey(chatId):
      self.messageList[chatId].setInitialMessagesLoaded(value)

  proc switchToMessage*(self: MessageView, messageId: string) =
    if (self.isMessageDisplayed(messageId)):
      self.searchedMessageLoaded(messageId)
    else:
      self.loadMessagesUntillMessageWithIdIsLoaded(messageId)

  proc downloadMessages*(self: MessageView, filePath: string) {.slot.} =
    let messages = newJArray()
    for message in self.messageList[self.channelView.activeChannel.id].messages:
      if message.id == "":
        continue

      messages.elems.add(%*{
        "id": message.id, "text": message.text, "clock": message.clock,
        "alias": message.alias, "from": message.fromAuthor
      })

    writeFile(url_toLocalFile(filePath), $messages)
