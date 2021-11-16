import
  ../core/tasks/marathon/mailserver/worker,
  status/signals

proc handleSignals(self: ChatController) =
  self.status.events.on(SignalType.Message.event) do(e:Args):
    var data = MessageSignal(e)
    self.status.chat.update(data.chats, data.messages, data.emojiReactions, data.communities, data.membershipRequests, data.pinnedMessages, data.activityCenterNotification, data.statusUpdates, data.deletedMessages)

  self.status.events.on(SignalType.EnvelopeSent.event) do(e:Args):
    var data = EnvelopeSentSignal(e)
    self.status.messages.updateStatus(data.messageIds)

  self.status.events.on(SignalType.EnvelopeExpired.event) do(e:Args):
    var data = EnvelopeExpiredSignal(e)
    for messageId in data.messageIds:
      if self.status.messages.messages.hasKey(messageId):
        let chatId = self.status.messages.messages[messageId].chatId
        self.view.messageView.messageList[chatId].checkTimeout(messageId)

  self.status.events.on(SignalType.CommunityFound.event) do(e: Args):
    var data = CommunitySignal(e)
    self.view.communities.addCommunityToList(data.community)

  self.status.events.on(SignalType.HistoryRequestStarted.event) do(e:Args):
    self.view.messageView.setLoadingMessages(true)

  self.status.events.on(SignalType.HistoryRequestCompleted.event) do(e:Args):
    self.view.messageView.setLoadingMessages(false)

  self.status.events.on(SignalType.HistoryRequestFailed.event) do(e:Args):
    self.view.messageView.setLoadingMessages(false)

  let mailserverWorker = self.appService.marathon[MailserverWorker().name]  
  self.status.events.on(SignalType.MailserverAvailable.event) do(e:Args):
    var data = MailserverAvailableSignal(e)
    info "active mailserver changed", node=data.address, topics="mailserver-interaction"
    self.view.messageView.setLoadingMessages(true)
    let task = RequestMessagesTaskArg(
      `method`: "requestMessages",
      vptr: cast[ByteAddress](self.view.vptr)
    )
    mailserverWorker.start(task)
