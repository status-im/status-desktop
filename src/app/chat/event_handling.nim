
proc handleChatEvents(self: ChatController) =
  # Display already saved messages
  self.status.events.on("messagesLoaded") do(e:Args):
    self.view.pushMessages(MsgsLoadedArgs(e).messages)

  self.status.events.on("contactUpdate") do(e: Args):
    var evArgs = ContactUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)

  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)
    self.view.updateChats(evArgs.chats)
    self.view.pushMessages(evArgs.messages)

  self.status.events.on("chatHistoryCleared") do(e: Args):
    var args = ChannelArgs(e)
    self.view.clearMessages(args.chat.id)

  self.status.events.on("channelLoaded") do(e: Args):
    var channel = ChannelArgs(e)
    discard self.view.chats.addChatItemToList(channel.chat)
    self.status.chat.chatMessages(channel.chat.id)

  self.status.events.on("chatsLoaded") do(e:Args):
    self.view.calculateUnreadMessages()
    self.view.setActiveChannelByIndex(0)

  self.status.events.on("channelJoined") do(e: Args):
    var channel = ChannelArgs(e)
    discard self.view.chats.addChatItemToList(channel.chat)
    self.status.chat.chatMessages(channel.chat.id)
    self.view.setActiveChannel(channel.chat.id)

  self.status.events.on("channelLeft") do(e: Args):
    self.view.removeChat(self.view.activeChannel.chatItem.id)

  self.status.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChatIdArg(e).chatId)

  self.status.events.on("sendingMessage") do(e:Args):
    var msg = MessageArgs(e)
    self.status.messages.trackMessage(msg.id, msg.channel)
    self.view.sendingMessage()

  self.status.events.on("messageSent") do(e:Args):
    var msg = MessageSentArgs(e)
    self.view.markMessageAsSent(msg.chatId, msg.id)

  self.status.events.on("chat:disconnected") do(e: Args):
    self.view.setConnected(false)

  self.status.events.on("chat:connected") do(e: Args):
    self.view.setConnected(true)

proc handleMailserverEvents(self: ChatController) =
  self.status.events.on("mailserverTopics") do(e: Args):
    self.status.mailservers.addTopics(TopicArgs(e).topics)
    if(self.status.mailservers.isSelectedMailserverAvailable):
      self.status.mailservers.requestMessages()

  self.status.events.on("mailserverAvailable") do(e:Args):
    self.status.mailservers.requestMessages()
