import "../../status/chat" as status_chat

type ChatModel* = ref object

proc newChatModel*(): ChatModel =
  result = ChatModel()

proc sendMessage*(self: ChatModel, msg: string): string =
  echo "sending public message"
  status_chat.sendPublicChatMessage("test", msg)
