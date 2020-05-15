import NimQml
import "../status/chat" as status_chat
import chatView

var sendMessage = proc (msg: string): string =
  echo "sending public message"
  status_chat.sendPublicChatMessage("test", msg)

type ChatController* = ref object
  view*: ChatsView
  variant*: QVariant

proc newController*(): ChatController =
  result = ChatController()
  result.view = newChatsView(sendMessage)
  result.view.names = @[]
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.view
  delete self.variant

proc init*(self: ChatController) =
  discard

proc join*(self: ChatController, chatId: string) =
  # TODO: check whether we have joined a chat already or not
  # TODO: save chat list in the db
  echo "Joining chat: ", chatId
  status_chat.loadFilters(chatId)
  status_chat.saveChat(chatId)
  status_chat.chatMessages(chatId)
  # self.chatsModel.addNameTolist(channel.name)
  self.view.addNameTolist(chatId)

proc load*(self: ChatController): seq[string] =
  # TODO: retrieve chats from DB
  self.join("test")
  result = @["test"]
