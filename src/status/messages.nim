import tables, sets, eventemitter
import libstatus/chat

type
  MessageDetails* = object
    status*: string
    chatId*: string

  MessagesModel* = ref object
    events*: EventEmitter
    messages*: Table[string, MessageDetails]
    confirmations*: HashSet[string]

  MessageSentArgs* = ref object of Args
    id*: string
    chatId*: string

proc newMessagesModel*(events: EventEmitter): MessagesModel =
  result = MessagesModel()
  result.events = events
  result.messages = initTable[string, MessageDetails]()
  result.confirmations = initHashSet[string]()

proc delete*(self: MessagesModel) =
  discard

# For each message sent we call trackMessage to register the message id,
# and wait until an EnvelopeSent signals is emitted for that message. However
# due to communication being async, it's possible that the signal arrives
# first, hence why we check if there's a confirmation (an envelope.sent) 
# inside trackMessage to emit the "messageSent" event

proc trackMessage*(self: MessagesModel, id: string, chatId: string) =
  if self.messages.hasKey(id): return

  self.messages[id] = MessageDetails(status: "sending", chatId: chatId)
  if self.confirmations.contains(id):
    self.confirmations.excl(id)
    self.messages[id].status = "sent"
    discard updateOutgoingMessageStatus(id, "sent")
    self.events.emit("messageSent", MessageSentArgs(id: id, chatId: chatId))

proc updateStatus*(self: MessagesModel, messageIds: seq[string]) =
  for messageId in messageIds:
    if self.messages.hasKey(messageId):
      self.messages[messageId].status = "sent"
      discard updateOutgoingMessageStatus(messageId, "sent")
      self.events.emit("messageSent", MessageSentArgs(id: messageId, chatId: self.messages[messageId].chatId))
    else:
      self.confirmations.incl(messageId)
