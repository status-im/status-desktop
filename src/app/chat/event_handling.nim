import # std libs
  strutils

import # status-desktop libs
  status/chat/chat as status_chat,
  ./views/communities,
  ./views/messages
import ../../app_service/tasks/[qt, threadpool]
import ../../app_service/tasks/marathon/mailserver/worker

proc handleChatEvents(self: ChatController) =
  # Display already saved messages
  self.status.events.on("messagesLoaded") do(e:Args):
    let evArgs = MsgsLoadedArgs(e)
    self.view.onMessagesLoaded(evArgs.chatId, evArgs.messages)
    for statusUpdate in evArgs.statusUpdates:
      self.view.communities.updateMemberVisibility(statusUpdate)

  # Display emoji reactions
  self.status.events.on("reactionsLoaded") do(e:Args):
    self.view.reactions.push(ReactionsLoadedArgs(e).reactions)
  # Display already pinned messages
  self.status.events.on("pinnedMessagesLoaded") do(e:Args):
    self.view.pushPinnedMessages(MsgsLoadedArgs(e).messages)
  self.status.events.on("searchMessagesLoaded") do(e:Args):
    self.view.onSearchMessagesLoaded(MsgsLoadedArgs(e).messages)

  self.status.events.on("activityCenterNotificationsLoaded") do(e:Args):
    let notifications = ActivityCenterNotificationsArgs(e).activityCenterNotifications
    self.view.pushActivityCenterNotifications(notifications)

  self.status.events.on("contactUpdate") do(e: Args):
    var evArgs = ContactUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)
    self.view.updateChannelForContacts(evArgs.contacts)

  # DO NOT ADD ANY LOGIC IN CHAT UPDATE
  # If you are emitting this event or handling new logic, you are probably
  # doing something wrong. The solution to your problem is probably
  # to add a dedicated event. Adding more logic here can only cause the 
  # app to be slower
  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.hideLoadingIndicator()
    self.view.updateChats(evArgs.chats)
    self.view.pushMessages(evArgs.messages)
    self.view.pushMembers(evArgs.chats)

    # TODO: update current user status (once it's possible to switch between ONLINE and DO_NOT_DISTURB)

    for statusUpdate in evArgs.statusUpdates:
      self.view.communities.updateMemberVisibility(statusUpdate)            

    for message in evArgs.messages:
      if (message.replace != ""):
        # Delete the message that this message replaces
        if (not self.view.deleteMessage(message.chatId, message.replace)):
          # In cases where new message need to replace a message which already replaced initial message 
          # "replace" property contains id of the initial message, but not the id of the message which 
          # replaced the initial one. That's why we call this proce here in case message with "message.replace"
          # was not deleted.
          discard self.view.deleteMessageWhichReplacedMessageWithId(message.chatId, message.replace)
      if (message.deleted):
        discard self.view.deleteMessage(message.chatId, message.id)


    self.view.reactions.push(evArgs.emojiReactions)
    if (evArgs.communities.len > 0):
      for community in evArgs.communities.mitems:
        if self.view.communities.isUserMemberOfCommunity(community.id) and not community.admin and not community.isMember:
          discard self.view.communities.leaveCommunity(community.id)
          continue
        
        self.view.communities.addCommunityToList(community)
        if (self.view.communities.activeCommunity.active and self.view.communities.activeCommunity.communityItem.id == community.id):
          if (self.view.channelView.activeChannel.chatItem != nil):
            let communityChannel = self.view.communities.activeCommunity.chats.getChannelById(self.view.channelView.activeChannel.chatItem.id)
            if communityChannel != nil:
              self.view.channelView.activeChannel.chatItem.canPost = communityChannel.canPost
          self.view.activeChannelChanged()

    if (evArgs.communityMembershipRequests.len > 0):
      self.view.communities.addMembershipRequests(evArgs.communityMembershipRequests)
    if (evArgs.pinnedMessages.len > 0):
      self.view.refreshPinnedMessages(evArgs.pinnedMessages)
    if (evArgs.activityCenterNotifications.len > 0):
      self.view.addActivityCenterNotification(evArgs.activityCenterNotifications)

    if (evArgs.deletedMessages.len > 0):
      for m in evArgs.deletedMessages:
        discard self.view.deleteMessage(m.chatId, m.messageId)

  self.status.events.on("channelUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.updateChats(evArgs.chats)

  self.status.events.on("messageDeleted") do(e: Args):
    var evArgs = MessageArgs(e)
    discard self.view.deleteMessage(evArgs.channel, evArgs.id)

  self.status.events.on("chatHistoryCleared") do(e: Args):
    var args = ChannelArgs(e)
    self.view.clearMessages(args.chat.id)

  self.status.events.on("channelLoaded") do(e: Args):
    var channel = ChannelArgs(e)
    if channel.chat.chatType == ChatType.Timeline:
      self.view.setTimelineChat(channel.chat)
    # Do not add community chats to the normal chat list
    elif channel.chat.chatType != ChatType.Profile and channel.chat.chatType != status_chat.ChatType.CommunityChat:
      discard self.view.channelView.chats.addChatItemToList(channel.chat)
      self.view.messageView.upsertChannel(channel.chat.id)
      self.view.messageView.messageList[channel.chat.id].addChatMembers(channel.chat.members)

    if channel.chat.chatType == status_chat.ChatType.CommunityChat:
      self.view.communities.updateCommunityChat(channel.chat)
    self.loadInitialMessagesForChannel(channel.chat.id)
  
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
      discard self.view.channelView.chats.addChatItemToList(channel.chat)
      self.view.setActiveChannel(channel.chat.id)

    self.loadInitialMessagesForChannel(channel.chat.id)
    self.status.chat.statusUpdates()

  self.status.events.on("channelLeft") do(e: Args):
    let chatId = ChatIdArg(e).chatId
    self.view.removeChat(chatId)
    self.view.calculateUnreadMessages()
    self.view.removeMessagesFromTimeline(chatId)

  self.status.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChatIdArg(e).chatId)

  self.status.events.on("messageSendingSuccess") do(e:Args):
    let event = MessageSendingSuccess(e)
    self.status.messages.trackMessage(event.message.id, event.chat.id)
    var messages = @[event.message]
    self.view.pushMessages(messages)
    self.view.messageView.calculateUnreadMessages()
    self.view.sendingMessageSuccess()

  self.status.events.on("messageSendingFailed") do(e:Args):
    var msg = MessageArgs(e)
    self.view.sendingMessageFailed()

  self.status.events.on("messageSent") do(e:Args):
    var msg = MessageSentArgs(e)
    self.view.markMessageAsSent(msg.chatId, msg.messageId)

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

  self.status.events.on("markNotificationsAsRead") do(e:Args):
    let markAsReadProps = MarkAsReadNotificationProperties(e)

    #Notifying communities about this change.
    self.view.communities.markNotificationsAsRead(markAsReadProps)

proc handleMailserverEvents(self: ChatController) =
  let mailserverWorker = self.appService.marathon[MailserverWorker().name]
  # TODO: test mailserver topics when joining chat
  
  self.status.events.on("channelJoined") do(e:Args):
    let task = IsActiveMailserverAvailableTaskArg(
      `method`: "isActiveMailserverAvailable",
      vptr: cast[ByteAddress](self.view.vptr),
      slot: "isActiveMailserverResult"
    )
    mailserverWorker.start(task)
  self.status.events.on("mailserverAvailable") do(e:Args):
    self.view.messageView.setLoadingMessages(true)
    let task = RequestMessagesTaskArg(
      `method`: "requestMessages",
      vptr: cast[ByteAddress](self.view.vptr),
      slot: "requestAllHistoricMessagesResult"
    )
    mailserverWorker.start(task)

proc handleSystemEvents(self: ChatController) =
  self.status.events.on("osNotificationClicked") do(e:Args):
    let arg = OsNotificationsArgs(e)
    self.view.onOsNotificationClicked(arg.details)