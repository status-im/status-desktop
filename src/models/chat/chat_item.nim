import ../../signals/types

type ChatItem* = ref object
  id*: string
  name*: string
  chatType*: ChatType
  lastMessage*: string
  timestamp*: int64
  unviewedMessagesCount*: int
  color*: string

proc newChatItem*(): ChatItem =
  new(result)
  result.name = ""
  result.lastMessage = ""
  result.timestamp = 0
  result.unviewedMessagesCount = 0
  result.color = ""

proc findById*(self: seq[ChatItem], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc chatName(chat: Chat): string =
  case chat.chatType
  of ChatType.OneToOne: result = chat.lastMessage.alias
  of ChatType.Public: result = chat.name
  of ChatType.PrivateGroupChat: result = "TODO: determine private group name"

proc toChatItem*(chat: Chat): ChatItem =
    result = ChatItem(
      id: chat.id,
      name: chatName(chat),
      chatType: chat.chatType,
      lastMessage: chat.lastMessage.text,
      timestamp: chat.timestamp,
      unviewedMessagesCount: chat.unviewedMessagesCount
    )
