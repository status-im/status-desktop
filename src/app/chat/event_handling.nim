import sugar, sequtils, times, strutils
import ../../status/chat/chat as status_chat
import ./views/communities

proc handleChatEvents(self: ChatController) =
  # Display already saved messages
  self.status.events.on("messagesLoaded") do(e:Args):
    self.view.pushMessages(MsgsLoadedArgs(e).messages)
  # Display emoji reactions
  self.status.events.on("reactionsLoaded") do(e:Args):
    self.view.reactions.push(ReactionsLoadedArgs(e).reactions)

  self.status.events.on("contactUpdate") do(e: Args):
    var evArgs = ContactUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)
    self.view.updateChannelForContacts(evArgs.contacts)

  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.hideLoadingIndicator()
    self.view.updateUsernames(evArgs.contacts)
    self.view.updateChats(evArgs.chats)
    self.view.pushMessages(evArgs.messages)
    for message in evArgs.messages:
      if (message.replace != ""):
        # Delete the message that this message replaces
        self.view.deleteMessage(message.chatId, message.replace)
    self.view.reactions.push(evArgs.emojiReactions)
    if (evArgs.communities.len > 0):
      for community in evArgs.communities:
        self.view.communities.addCommunityToList(community)
    if (evArgs.communityMembershipRequests.len > 0):
      self.view.communities.addMembershipRequests(evArgs.communityMembershipRequests)

  self.status.events.on("channelUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.updateChats(evArgs.chats)

  self.status.events.on("messageDeleted") do(e: Args):
    var evArgs = MessageArgs(e)
    self.view.deleteMessage(evArgs.channel, evArgs.id)

  self.status.events.on("chatHistoryCleared") do(e: Args):
    var args = ChannelArgs(e)
    self.view.clearMessages(args.chat.id)

  self.status.events.on("channelLoaded") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.chatType == ChatType.Timeline:
      self.view.setTimelineChat(channel.chat)
    # Do not add community chats to the normal chat list
    elif channel.chat.chatType != ChatType.Profile and channel.chat.chatType != status_chat.ChatType.CommunityChat:
      discard self.view.chats.addChatItemToList(channel.chat)
    self.view.asyncMessageLoad(channel.chat.id)

  self.status.events.on("chatsLoaded") do(e:Args):
    self.view.calculateUnreadMessages()
    self.view.setActiveChannelByIndex(0)
    self.view.appReady()

  self.status.events.on("communityActiveChanged") do(e:Args):
    var evArgs = CommunityActiveChangedArgs(e)
    if (evArgs.active == false):
      self.view.restorePreviousActiveChannel()
    else:
      if (self.view.communities.activeCommunity.communityItem.lastChannelSeen == ""):
        self.view.setActiveChannelByIndex(0)
      else:
        self.view.setActiveChannel(self.view.communities.activeCommunity.communityItem.lastChannelSeen)

  self.status.events.on("channelJoined") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.chatType == ChatType.Timeline:
      self.view.setTimelineChat(channel.chat)
    elif channel.chat.chatType != ChatType.Profile:
      discard self.view.chats.addChatItemToList(channel.chat)
      self.view.setActiveChannel(channel.chat.id)
    self.status.chat.chatMessages(channel.chat.id)
    self.status.chat.chatReactions(channel.chat.id)

  self.status.events.on("channelLeft") do(e: Args):
    let chatId = ChatIdArg(e).chatId
    self.view.removeChat(chatId)
    self.view.removeMessagesFromTimeline(chatId)

  self.status.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChatIdArg(e).chatId)

  self.status.events.on("sendingMessage") do(e:Args):
    var msg = MessageArgs(e)
    self.status.messages.trackMessage(msg.id, msg.channel)
    self.view.sendingMessage()

  self.status.events.on("sendingMessageFailed") do(e:Args):
    var msg = MessageArgs(e)
    self.view.sendingMessageFailed()

  self.status.events.on("messageSent") do(e:Args):
    var msg = MessageSentArgs(e)
    self.view.markMessageAsSent(msg.chatId, msg.id)

  self.status.events.on("network:disconnected") do(e: Args):
    self.view.setConnected(false)

  self.status.events.on("network:connected") do(e: Args):
    self.view.setConnected(true)

  self.status.events.on(PendingTransactionType.BuyStickerPack.confirmed) do(e: Args):
    var tx = TransactionMinedArgs(e)
    self.view.stickers.transactionCompleted(tx.success, tx.transactionHash, tx.revertReason)
    if tx.success:
      self.view.stickers.install(tx.data.parseInt)
    else:
      self.view.stickers.resetBuyAttempt(tx.data.parseInt)

proc handleMailserverEvents(self: ChatController) =
  self.status.events.on("mailserverTopics") do(e: Args):
    var topics = TopicArgs(e).topics
    for topic in topics:
      topic.lastRequest = times.toUnix(times.getTime())
      self.status.mailservers.addMailserverTopic(topic)

    if(self.status.mailservers.isActiveMailserverAvailable):
      self.view.setLoadingMessages(true)
      self.status.mailservers.requestMessages(topics.map(t => t.topic))

  self.status.events.on("mailserverAvailable") do(e:Args):
    let mailserverTopics = self.status.mailservers.getMailserverTopics()
    var fromValue = times.toUnix(times.getTime()) - 86400 # today - 24 hours

    if mailserverTopics.len > 0:
       fromValue = min(mailserverTopics.map(topic => topic.lastRequest))
    
    self.view.setLoadingMessages(true)
    self.status.mailservers.requestMessages(mailserverTopics.map(t => t.topic), fromValue)
