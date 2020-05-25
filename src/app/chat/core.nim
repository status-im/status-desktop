import NimQml
import json, eventemitter
import ../../models/chat as chat_model
import ../../signals/types
import ../../status/types as status_types
import view
import chronicles

logScope:
  topics = "chat-controller"

type ChatController* = ref object of SignalSubscriber
  view*: ChatsView
  model*: ChatModel
  variant*: QVariant
  appEvents*: EventEmitter

proc newController*(appEvents: EventEmitter): ChatController =
  result = ChatController()
  result.appEvents = appEvents
  result.model = newChatModel()
  result.view = newChatsView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.view
  delete self.variant

proc init*(self: ChatController) =
  self.model.events.on("messageSent") do(e: Args):
    var sentMessage = MsgArgs(e)
    var chatMessage = sentMessage.payload.toChatMessage()
    chatMessage.message = sentMessage.message
    chatMessage.isCurrentUser = true

    self.view.pushMessage(sentMessage.chatId, chatMessage)

proc load*(self: ChatController, chatId: string) =
  # TODO: we need a function to load the channels from the db.
  #       and... called from init() instead from nim_status_client
  discard self.view.joinChat(chatId)
  self.view.setActiveChannelByIndex(0)

proc handleMessage(self: ChatController, data: Signal) =
  var messageSignal = cast[MessageSignal](data)

  for c in messageSignal.chats:
   let channel = c.toChatItem()
   self.view.updateChat(channel)

  for message in messageSignal.messages:
    let chatMessage = message.toChatMessage()
    self.view.pushMessage(message.localChatId, chatMessage)

proc handleWhisperFilter(self: ChatController, data: Signal) = 
  echo "Do something"

method onSignal(self: ChatController, data: Signal) =
  case data.signalType: 
  of SignalType.Message: handleMessage(self, data)
  of SignalType.WhisperFilterAdded: handleWhisperFilter(self, data)
  else:
    warn "Unhandled signal received", signalType = data.signalType
