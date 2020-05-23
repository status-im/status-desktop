import NimQml
import json, eventemitter
import ../../status/chat as status_chat
import view
import ../signals/types
import ../../models/chat as chat_model

type ChatController* = ref object of SignalSubscriber
  view*: ChatsView
  model*: ChatModel
  variant*: QVariant

proc newController*(events: EventEmitter): ChatController =
  result = ChatController()
  result.model = newChatModel(events)
  result.view = newChatsView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.view
  delete self.variant

proc init*(self: ChatController) =
  self.model.events.on("messageSent") do(e: Args):
    var sentMessage = MsgArgs(e)

    let chatMessage = newChatMessage()
    chatMessage.userName = sentMessage.payload["alias"].str
    chatMessage.message = sentMessage.message
    chatMessage.timestamp = $sentMessage.payload["timestamp"]
    chatMessage.identicon = sentMessage.payload["identicon"].str
    chatMessage.isCurrentUser = true

    self.view.pushMessage(sentMessage.chatId, chatMessage)

proc load*(self: ChatController, chatId: string) =
  # TODO: we need a function to load the channels from the db.
  #       and... called from init() instead from nim_status_client
  discard self.view.joinChat(chatId)
  self.view.setActiveChannelByIndex(0)

method onSignal(self: ChatController, data: Signal) =
  var messageSignal = cast[MessageSignal](data)

  for c in messageSignal.chats:
    let channel = newChatitem()
    channel.name = c.name
    channel.lastMessage = c.lastMessage.text
    channel.timestamp = c.timestamp
    channel.unviewedMessagesCount = c.unviewedMessagesCount
    self.view.updateChat(channel)

  for message in messageSignal.messages:
    let chatMessage = newChatMessage()
    chatMessage.userName = message.alias
    chatMessage.message = message.text
    chatMessage.timestamp = message.timestamp #TODO convert to date/time?
    chatMessage.identicon = message.identicon
    chatMessage.isCurrentUser = message.isCurrentUser
    self.view.pushMessage(message.chatId, chatMessage)
