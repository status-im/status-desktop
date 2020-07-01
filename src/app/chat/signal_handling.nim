
proc handleMessage(self: ChatController, data: MessageSignal) =
  self.status.chat.update(data.chats, data.messages)

proc handleDiscoverySummary(self: ChatController, data: DiscoverySummarySignal) =
  ## Handle mailserver peers being added and removed
  self.status.mailservers.peerSummaryChange(data.enodes)

proc handleEnvelopeSent(self: ChatController, data: EnvelopeSentSignal) =
  self.status.messages.updateStatus(data.messageIds)
