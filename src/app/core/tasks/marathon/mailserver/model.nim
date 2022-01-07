import chronos, chronicles
import ../../../../../app_service/service/node_configuration/service_interface as node_config_service
import controller

logScope:
  topics = "mailserver model"

type
  MailserverModel* = ref object
    mailserverController: MailserverController

proc newMailserverModel*(vptr: ByteAddress): MailserverModel =
  result = MailserverModel()
  result.mailserverController = cast[MailserverController](vptr)

proc disconnectActiveMailserver(self: MailserverModel) =
  try:
    warn "Disconnecting active mailserver due to error"
    self.mailserverController.disconnectActiveMailserver()
  except Exception as e:
    error "error: ", errDescription=e.msg

proc requestMessages*(self: MailserverModel) =
  try:
    info "Requesting message history"
    self.mailserverController.requestAllHistoricMessages()
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()

proc requestMoreMessages*(self: MailserverModel, chatId: string) =
  try:
    info "Requesting more messages for", chatId=chatId
    self.mailserverController.syncChatFromSyncedFrom(chatId)
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()

proc fillGaps*(self: MailserverModel, chatId: string, messageIds: seq[string]) =
  try:
    info "Requesting fill gaps from", chatId=chatId
    self.mailserverController.fillGaps(chatId, messageIds)
  except Exception as e:
    error "error: ", errDescription=e.msg
    self.disconnectActiveMailserver()
