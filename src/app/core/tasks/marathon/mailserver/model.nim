import
  chronos, chronicles

import
  status/statusgo_backend_new/mailservers as status_mailservers,
  status/fleet
  
logScope:
  topics = "mailserver model"

type
  MailserverModel* = ref object

proc newMailserverModel*(vptr: ByteAddress): MailserverModel =
  result = MailserverModel()

proc disconnectActiveMailserver(self: MailserverModel) =
  try:
    warn "Disconnecting active mailserver due to error"
    discard status_mailservers.disconnectActiveMailserver()
  except Exception as e:
    error "error: ", errDescription=e.msg

proc requestMessages*(self: MailserverModel) =
  try:
    info "Requesting message history"
    discard status_mailservers.requestAllHistoricMessages()
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()

proc requestMoreMessages*(self: MailserverModel, chatId: string) =
  try:
    info "Requesting more messages for", chatId=chatId
    discard status_mailservers.syncChatFromSyncedFrom(chatId)
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()

proc fillGaps*(self: MailserverModel, chatId: string, messageIds: seq[string]) =
  try:
    info "Requesting fill gaps from", chatId=chatId
    discard status_mailservers.fillGaps(chatId, messageIds)
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()
