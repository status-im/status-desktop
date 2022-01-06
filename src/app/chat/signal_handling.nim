import
  ../../app_service/tasks/marathon/mailserver/worker,
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

  self.status.events.on(SignalType.MailserverRequestCompleted.event) do(e:Args):
    # TODO: if the signal contains a cursor, request additional messages
    # else: 
    self.view.hideLoadingIndicator()

  self.status.events.on(SignalType.MailserverRequestExpired.event) do(e:Args):
    # TODO: retry mailserver request up to N times or change mailserver
    # If > N, then
    self.view.hideLoadingIndicator()

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
