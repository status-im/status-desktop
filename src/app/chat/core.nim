import NimQml
import json, eventemitter
import ../../models/chat as chat_model
import ../../signals/types
import ../../status/types as status_types
import views/channels_list
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
  self.model.events.on("chatsLoaded") do(e: Args):
    var chatArgs = ChatArgs(e)
    for c in chatArgs.chats:
      self.view.pushChatItem(c.toChatItem)

  self.model.events.on("messageSent") do(e: Args):
    var sentMessage = MsgArgs(e)
    var chatMessage = sentMessage.payload.toChatMessage()
    chatMessage.message = sentMessage.message
    chatMessage.isCurrentUser = true
    self.view.pushMessage(sentMessage.chatId, chatMessage)

  self.model.events.on("channelJoined") do(e: Args):
    var channelMessage = ChannelArgs(e)
    let chatItem = newChatItem(id = channelMessage.channel, channelMessage.chatTypeInt)
    discard self.view.chats.addChatItemToList(chatItem)

  self.model.events.on("channelLeft") do(e: Args):
    discard self.view.chats.removeChatItemFromList(self.view.activeChannel)

  self.model.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChannelArgs(e).channel)

  self.model.load()
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
