import "../status/chat" as status_chat

proc join*(chatId: string) =
  # TODO: check whether we have joined a chat already or not
  # TODO: save chat list in the db
  echo "Joining chat: ", chatId
  status_chat.loadFilters(chatId)
  status_chat.saveChat(chatId)
  status_chat.chatMessages(chatId)
  
proc load*(): seq[string] =
  # TODO: retrieve chats from DB
  join("test")
  result = @["test"]

