import NimQml
import json, sets, eventemitter
import ../../status/chat as status_chat
import view
import messages
import ../signals/types
import ../../models/chat

var sendMessage = proc (view: ChatsView, chatId: string, msg: string): string =
  echo "sending public message!"
  var sentMessage = status_chat.sendChatMessage(chatId, msg)
  var parsedMessage = parseJson(sentMessage)["result"]["chats"][0]["lastMessage"]

  let chatMessage = newChatMessage()
  chatMessage.userName = parsedMessage["alias"].str
  chatMessage.message = msg
  chatMessage.timestamp = $parsedMessage["timestamp"]
  chatMessage.identicon = parsedMessage["identicon"].str
  chatMessage.isCurrentUser = true

  view.pushMessage(chatId, chatMessage)
  sentMessage

type ChatController* = ref object of SignalSubscriber
  view*: ChatsView
  model*: ChatModel
  variant*: QVariant

proc newController*(events: EventEmitter): ChatController =
  result = ChatController()
  result.model = newChatModel(events)
  result.view = newChatsView(result.model, sendMessage)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.view
  delete self.variant

proc init*(self: ChatController) =
  discard

proc load*(self: ChatController, chatId: string) =
  # TODO: we need a function to load the channels from the db.
  #       and... called from init() instead from nim_status_client
  discard self.view.joinChat(chatId)
  self.view.setActiveChannelByIndex(0)

method onSignal(self: ChatController, data: Signal) =
  var chatSignal = cast[ChatSignal](data)
  for message in chatSignal.messages:
    let chatMessage = newChatMessage()
    chatMessage.userName = message.alias
    chatMessage.message = message.text
    chatMessage.timestamp = message.timestamp #TODO convert to date/time?
    chatMessage.identicon = message.identicon
    chatMessage.isCurrentUser = message.isCurrentUser
    self.view.pushMessage(message.chatId, chatMessage)
