import NimQml
import "../status/chat" as status_chat
import chatView

var sendMessage = proc (msg: string): string =
  echo "sending public message"
  status_chat.sendPublicChatMessage("test", msg)

type Chat* = ref object
  chatsModel*: ChatsModel
  chatsVariant*: QVariant

proc newChat*(): Chat =
  result = Chat()
  result.chatsModel = newChatsModel(sendMessage)
  result.chatsModel.names = @[]
  result.chatsVariant = newQVariant(result.chatsModel)

proc delete*(self: Chat) =
  delete self.chatsModel
  delete self.chatsVariant

proc init*(self: Chat) =
  discard

proc join*(self: Chat, chatId: string) =
  # TODO: check whether we have joined a chat already or not
  # TODO: save chat list in the db
  echo "Joining chat: ", chatId
  status_chat.loadFilters(chatId)
  status_chat.saveChat(chatId)
  status_chat.chatMessages(chatId)
  # self.chatsModel.addNameTolist(channel.name)
  self.chatsModel.addNameTolist(chatId)

proc load*(self: Chat): seq[string] =
  # TODO: retrieve chats from DB
  self.join("test")
  result = @["test"]
