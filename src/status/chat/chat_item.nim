import ../../signals/types
import ../libstatus/accounts as status_accounts

type ChatItem* = ref object
  id*: string
  name*: string
  chatType*: ChatType
  lastMessage*: string
  timestamp*: int64
  unviewedMessagesCount*: int
  color*: string
  identicon*: string

proc newChatItem*(id: string, chatType: ChatType, lastMessage: string = "", timestamp: int64 = 0, unviewedMessagesCount: int = 0, color: string = "", identicon: string = ""): ChatItem =
  new(result)
  result.id = id
  result.name = case chatType
              of ChatType.Public: id
              of ChatType.OneToOne: generateAlias(id)
              of ChatType.PrivateGroupChat: "TODO: Private Group Name"
              of ChatType.Unknown: "Unknown: " & id
  result.chatType = chatType
  result.lastMessage = lastMessage
  result.timestamp = timestamp
  result.unviewedMessagesCount = unviewedMessagesCount
  result.color = color
  result.identicon = if identicon == "" and chatType == ChatType.OneToOne: 
                       generateIdenticon(id) 
                     else: 
                       identicon

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
  of ChatType.Unknown: result = "Unknown"

proc toChatItem*(chat: Chat): ChatItem =
    result = ChatItem(
      id: chat.id,
      name: chatName(chat),
      color: chat.color,
      chatType: chat.chatType,
      lastMessage: chat.lastMessage.text,
      timestamp: chat.timestamp,
      identicon: chat.lastMessage.identicon,
      unviewedMessagesCount: chat.unviewedMessagesCount
    )
