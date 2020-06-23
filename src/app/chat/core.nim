import NimQml, eventemitter, chronicles
import ../../status/chat as chat_model
import ../../status/mailservers as mailserver_model
import ../../signals/types
import ../../status/libstatus/types as status_types
import ../../status/[chat, contacts, status]
import view, views/channels_list

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
  delete self.variant
  delete self.view

proc handleChatEvents(self: ChatController) =
  # Display already saved messages
  self.status.events.on("messagesLoaded") do(e:Args):
    self.view.pushMessages(MsgsLoadedArgs(e).messages)

  self.status.events.on("contactUpdate") do(e: Args):
    var evArgs = ContactUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)

  self.status.events.on("chatUpdate") do(e: Args):
    var evArgs = ChatUpdateArgs(e)
    self.view.updateUsernames(evArgs.contacts)
    self.view.updateChats(evArgs.chats)
    self.view.pushMessages(evArgs.messages)

  self.status.events.on("chatHistoryCleared") do(e: Args):
    var args = ChannelArgs(e)
    self.view.clearMessages(args.chat.id)

  self.status.events.on("channelJoined") do(e: Args):
    var channel = ChannelArgs(e)
    discard self.view.chats.addChatItemToList(channel.chat)
    self.status.chat.chatMessages(channel.chat.id)
    self.view.setActiveChannel(channel.chat.id)

  self.status.events.on("channelLeft") do(e: Args):
    discard self.view.chats.removeChatItemFromList(self.view.activeChannel.chatItem.id)

  self.status.events.on("activeChannelChanged") do(e: Args):
    self.view.setActiveChannel(ChatIdArg(e).chatId)

proc handleMailserverEvents(self: ChatController) =
  self.status.events.on("mailserverTopics") do(e: Args):
    self.status.mailservers.addTopics(TopicArgs(e).topics)
    if(self.status.mailservers.isSelectedMailserverAvailable):
      self.status.mailservers.requestMessages()

  self.status.events.on("mailserverAvailable") do(e:Args):
    self.status.mailservers.requestMessages()

proc init*(self: ChatController) =
  self.handleMailserverEvents()
  self.handleChatEvents()
  self.status.mailservers.init()
  self.status.chat.init()

proc handleMessage(self: ChatController, data: MessageSignal) =
  self.status.chat.update(data.chats, data.messages)

proc handleDiscoverySummary(self: ChatController, data: DiscoverySummarySignal) =
  ## Handle mailserver peers being added and removed
  self.status.mailservers.peerSummaryChange(data.enodes)

method onSignal(self: ChatController, data: Signal) =
  case data.signalType: 
  of SignalType.Message: handleMessage(self, MessageSignal(data))
  of SignalType.DiscoverySummary: handleDiscoverySummary(self, DiscoverySummarySignal(data))
  else:
    warn "Unhandled signal received", signalType = data.signalType
