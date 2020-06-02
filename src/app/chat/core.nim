import NimQml
import json, eventemitter, chronicles
import ../../status/chat as chat_model
import ../../status/mailservers as mailserver_model
import ../../signals/types
import ../../status/libstatus/types as status_types
import ../../signals/types
import ../../status/chat
import ../../status/status
import views/channels_list
import view

logScope:
  topics = "chat-controller"

type ChatController* = ref object of SignalSubscriber
  view*: ChatsView
  status*: Status
  variant*: QVariant

proc newController*(status: Status): ChatController =
  result = ChatController()
  result.status = status
  result.view = newChatsView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.view
  delete self.variant

proc handleChatEvents(self: ChatController) =
  self.status.events.on("messageSent") do(e: Args):
    var sentMessage = MsgArgs(e)
    var chatMessage = sentMessage.payload.toChatMessage()
    chatMessage.message = sentMessage.message
    chatMessage.isCurrentUser = true
    self.view.pushMessage(sentMessage.chatId, chatMessage)

  self.status.events.on("channelJoined") do(e: Args):
    var channelMessage = ChannelArgs(e)
    let chatItem = newChatItem(id = channelMessage.channel, channelMessage.chatTypeInt)
    discard self.view.chats.addChatItemToList(chatItem)

  self.status.events.on("channelLeft") do(e: Args):
    discard self.view.chats.removeChatItemFromList(self.view.activeChannel)

  self.status.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChannelArgs(e).channel)

proc init*(self: ChatController) =
  self.handleChatEvents()
  
  self.status.chat.init()
  self.status.mailservers.init()

  self.view.setActiveChannelByIndex(0)

proc handleMessage(self: ChatController, data: Signal) =
  var messageSignal = cast[MessageSignal](data)

  for c in messageSignal.chats:
   let channel = c.toChatItem()
   self.view.updateChat(channel)

  for message in messageSignal.messages:
    let chatMessage = message.toChatMessage()
    self.view.pushMessage(message.localChatId, chatMessage)

proc handleDiscoverySummary(self: ChatController, data: Signal) =
  var discovery = DiscoverySummarySignal(data)
  self.status.mailservers.peerSummaryChange(discovery.enodes)

method onSignal(self: ChatController, data: Signal) =
  case data.signalType: 
  of SignalType.Message: handleMessage(self, data)
  of SignalType.DiscoverySummary: handleDiscoverySummary(self, data)
  else:
    warn "Unhandled signal received", signalType = data.signalType
